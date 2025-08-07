package org.jeecg.modules.demo.lqMindmap.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.apache.shiro.SecurityUtils;
import org.jeecg.common.system.vo.LoginUser;
import org.jeecg.modules.demo.lqMindmap.entity.LqMindmap;
import org.jeecg.modules.demo.lqMindmap.mapper.LqMindmapMapper;
import org.jeecg.modules.demo.lqMindmap.service.ILqMindmapService;

import org.jeecg.modules.demo.lqMindmapTagRel.entity.LqMindmapTagRel;
import org.jeecg.modules.demo.lqMindmapTagRel.mapper.LqMindmapTagRelMapper;
import org.jeecg.modules.demo.lqMindmapVersion.entity.LqMindmapVersion;
import org.jeecg.modules.demo.lqMindmapVersion.mapper.LqMindmapVersionMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.fge.jsonpatch.JsonPatch;
import com.github.fge.jsonpatch.diff.JsonDiff;
import java.lang.reflect.Method;

/**
 * @Description: lq_mindmap
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Slf4j
@Service
public class LqMindmapServiceImpl extends ServiceImpl<LqMindmapMapper, LqMindmap> implements ILqMindmapService {

    @Autowired
    private LqMindmapVersionMapper versionMapper;

    @Autowired
    private LqMindmapTagRelMapper tagRelMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Value("${mindmap.encrypt-key}")
    private String encryptKey;

    @Value("${mindmap.max-content-size:10485760}")
    private long maxContentSize;

    @Value("${mindmap.auto-save-interval:30000}")
    private long autoSaveInterval;

    // 自动保存线程池
    private final ScheduledExecutorService autoSaveExecutor = Executors.newSingleThreadScheduledExecutor();

    // 自动保存任务映射
    private final ConcurrentHashMap<String, ScheduledFuture<?>> autoSaveTasks = new ConcurrentHashMap<>();

    // 自动保存内容缓存
    private final ConcurrentHashMap<String, String> contentCache = new ConcurrentHashMap<>();

    @Override
    public IPage<LqMindmap> queryUserMindmaps(Page<LqMindmap> page, String userId, String keyword) {
        QueryWrapper<LqMindmap> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId);
        if (keyword != null && !keyword.isEmpty()) {
            queryWrapper.like("name", keyword);
        }
        queryWrapper.orderByDesc("update_time");
        return baseMapper.selectPage(page, queryWrapper);
    }

    @Override
    public LqMindmap getLatestByUserId(String userId) {
        QueryWrapper<LqMindmap> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("user_id", userId);
        queryWrapper.orderByDesc("update_time");
        queryWrapper.last("limit 1");
        return baseMapper.selectOne(queryWrapper);
    }

    @Transactional
    @Override
    public boolean saveMindmap(LqMindmap mindmap, String content, boolean isKeyVersion, String remark) {
        // 停止自动保存任务（如果存在）
        stopAutoSave(mindmap.getId());

        // 检查内容是否变化
        if (mindmap.getId() != null) {
            LqMindmap oldMindmap = baseMapper.selectById(mindmap.getId());
            if (oldMindmap != null) {
                String oldContent = decryptContent(Base64.getDecoder().decode(oldMindmap.getContent()));
                if (oldContent.equals(content)) {
                    log.info("内容未变化，跳过保存");
                    return true;
                }
            }
        }

        // 加密内容
        byte[] encryptedContent = encryptContent(content);

        // 启动自动保存任务
        if (mindmap.getId() != null) {
            startAutoSave(mindmap.getId(), content);
        }
        // 将byte[]转换为Base64编码的字符串存储
        mindmap.setContent(Base64.getEncoder().encodeToString(encryptedContent));

        // 获取当前用户ID
        String currentUserId = null;
        LoginUser loginUser = (LoginUser) SecurityUtils.getSubject().getPrincipal();
        if (loginUser != null) {
            currentUserId = loginUser.getUsername();
        }

        Date now = new Date();
        boolean isNew = mindmap.getId() == null || mindmap.getId().isEmpty();

        if (isNew) {
            // 新创建
            mindmap.setUserId(currentUserId);
            mindmap.setCreateTime(now);
            mindmap.setUpdateTime(now);
            mindmap.setLatestVersion(1);
            mindmap.setIsShared(false);
            baseMapper.insert(mindmap);

            // 创建第一个版本
            LqMindmapVersion version = new LqMindmapVersion();
            version.setMindmapId(mindmap.getId());
            version.setVersion(1);
            // 将byte[]转换为Base64编码的字符串存储
            version.setContentDiff(Base64.getEncoder().encodeToString(encryptedContent)); // 第一个版本存储完整内容
            version.setCreateTime(now);
            version.setIsKeyVersion(isKeyVersion);
            version.setRemark(remark != null ? remark : "初始版本");
            version.setUserId(currentUserId);
            version.setTenantId(mindmap.getTenantId());
            versionMapper.insert(version);
        } else {
            // 更新现有思维导图
            LqMindmap oldMindmap = baseMapper.selectById(mindmap.getId());
            if (oldMindmap == null) {
                return false;
            }

            // 获取旧内容并解码
            byte[] decodedOldContent = Base64.getDecoder().decode(oldMindmap.getContent());
            String oldContent = decryptContent(decodedOldContent);

            // 计算差异（实际应用中应使用JSON差异库）
            byte[] contentDiff = encryptContent(getContentDiff(oldContent, content));

            // 更新主表
            mindmap.setUpdateTime(now);
            mindmap.setLatestVersion(oldMindmap.getLatestVersion() + 1);
            baseMapper.updateById(mindmap);

            // 创建新版本
            LqMindmapVersion version = new LqMindmapVersion();
            version.setMindmapId(mindmap.getId());
            version.setVersion(mindmap.getLatestVersion());
            // 将byte[]转换为Base64编码的字符串存储
            version.setContentDiff(Base64.getEncoder().encodeToString(contentDiff));
            version.setCreateTime(now);
            version.setIsKeyVersion(isKeyVersion);
            version.setRemark(remark != null ? remark : "更新版本");
            version.setUserId(currentUserId);
            version.setTenantId(mindmap.getTenantId());
            versionMapper.insert(version);

            // 检查版本数量，超过50个则删除 oldest 的非关键版本
            this.cleanupOldVersions(mindmap.getId());
        }

        return true;
    }



    @Override
    public String decryptContent(byte[] encryptedContent) {
        if (encryptedContent == null) {
            return null;
        }
        // 实际应用中应使用PostgreSQL的pgp_sym_decrypt函数
        String sql = "SELECT pgp_sym_decrypt(?, ?)";
        return jdbcTemplate.queryForObject(sql, String.class, encryptedContent, encryptKey);
    }

    @Override
    public byte[] encryptContent(String content) {
        if (content == null) {
            return null;
        }
        // 检查内容大小
        if (content.getBytes().length > maxContentSize) {
            throw new RuntimeException("内容大小超过限制: " + maxContentSize + "字节");
        }
        // 实际应用中应使用PostgreSQL的pgp_sym_encrypt函数
        String sql = "SELECT pgp_sym_encrypt(?, ?)";
        return jdbcTemplate.queryForObject(sql, byte[].class, content, encryptKey);
    }

    /**
     * 清理旧版本，只保留最近50个版本，关键版本除外
     */
    private void cleanupOldVersions(String mindmapId) {
        // 查询所有版本
        Wrapper<LqMindmapVersion> queryWrapper = new QueryWrapper<LqMindmapVersion>();
        queryWrapper.eq("mindmap_id", mindmapId);
        queryWrapper.orderByAsc("version");
        List<LqMindmapVersion> versions = versionMapper.selectList(queryWrapper);

        // 如果版本数超过50，删除旧版本（保留关键版本）
        if (versions.size() > 50) {
            int needToDelete = versions.size() - 50;
            int deletedCount = 0;

            for (LqMindmapVersion version : versions) {
                if (deletedCount >= needToDelete) {
                    break;
                }
                // 非关键版本才删除
                if (!version.getIsKeyVersion()) {
                    versionMapper.deleteById(version.getId());
                    deletedCount++;
                }
            }
        }
    }

    /**
     * 计算内容差异（简化实现，实际应使用专业JSON差异库）
     */
    private String getContentDiff(String oldContent, String newContent) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode source = mapper.readTree(oldContent);
            JsonNode target = mapper.readTree(newContent);
            JsonPatch patch = JsonDiff.asJsonPatch(source, target);
            return mapper.writeValueAsString(patch);
        } catch (Exception e) {
            log.error("计算JSON差异失败", e);
            return newContent; // 回退到存储完整内容
        }
    }

    /**
     * 计算两个JSON内容的差异（用于版本比较）
     */
    private String calculateJsonDiff(String content1, String content2) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode node1 = mapper.readTree(content1);
            JsonNode node2 = mapper.readTree(content2);

            // 使用JsonDiff计算差异
            JsonNode diff = JsonDiff.asJson(node1, node2);
            return mapper.writerWithDefaultPrettyPrinter().writeValueAsString(diff);
        } catch (Exception e) {
            log.error("计算JSON差异失败", e);
            return "无法计算差异: " + e.getMessage();
        }
    }

    @Override
    public String compareVersions(String mindmapId, Integer version1, Integer version2) {
        try {
            // 获取两个版本的内容
            LqMindmapVersion v1 = versionMapper.selectOne(new QueryWrapper<LqMindmapVersion>()
                    .eq("mindmap_id", mindmapId)
                    .eq("version", version1));

            LqMindmapVersion v2 = versionMapper.selectOne(new QueryWrapper<LqMindmapVersion>()
                    .eq("mindmap_id", mindmapId)
                    .eq("version", version2));

            if (v1 == null || v2 == null) {
                return "版本不存在";
            }

            // 解密内容
            String content1 = decryptContent(Base64.getDecoder().decode(v1.getContentDiff()));
            String content2 = decryptContent(Base64.getDecoder().decode(v2.getContentDiff()));

            // 计算并返回差异（简化实现）
            return calculateJsonDiff(content1, content2);
        } catch (Exception e) {
            log.error("计算版本差异失败", e);
            return "计算差异失败: " + e.getMessage();
        }
    }

    @Override
    public List<LqMindmapVersion> getVersionList(String mindmapId) {
        return versionMapper.selectList(
                (Wrapper<LqMindmapVersion>) new QueryWrapper<LqMindmapVersion>()
                        .eq("mindmap_id", mindmapId)
                        .orderByDesc("version"));
    }

    @Transactional
    @Override
    public boolean shareMindmap(String mindmapId, List<String> userIds, List<String> roleIds) {
        // 检查权限
        LqMindmap mindmap = baseMapper.selectById(mindmapId);
        if (mindmap == null) {
            throw new RuntimeException("思维导图不存在");
        }

        LoginUser loginUser = (LoginUser) SecurityUtils.getSubject().getPrincipal();
        String currentUserId = loginUser.getUsername();
        if (!mindmap.getUserId().equals(currentUserId)) {
            throw new RuntimeException("没有共享权限");
        }

        // 删除旧的共享记录
        jdbcTemplate.update("DELETE FROM lq_mindmap_share WHERE mindmap_id = ?", mindmapId);

        // 添加用户共享
        if (userIds != null && !userIds.isEmpty()) {
            for (String userId : userIds) {
                jdbcTemplate.update(
                        "INSERT INTO lq_mindmap_share (mindmap_id, user_id, create_time) VALUES (?, ?, ?)",
                        mindmapId, userId, new Date());
            }
        }

        // 添加角色共享
        if (roleIds != null && !roleIds.isEmpty()) {
            for (String roleId : roleIds) {
                jdbcTemplate.update(
                        "INSERT INTO lq_mindmap_share (mindmap_id, role_id, create_time) VALUES (?, ?, ?)",
                        mindmapId, roleId, new Date());
            }
        }

        // 更新主表共享状态
        mindmap.setIsShared(userIds != null && !userIds.isEmpty() || roleIds != null && !roleIds.isEmpty());
        baseMapper.updateById(mindmap);
        return true;
    }

    @Override
    public boolean checkSharePermission(String mindmapId, String userId) {
        // 检查是否是所有者
        LqMindmap mindmap = baseMapper.selectById(mindmapId);
        if (mindmap == null) {
            return false;
        }
        if (mindmap.getUserId().equals(userId)) {
            return true;
        }

        // 检查用户共享
        Integer userCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM lq_mindmap_share WHERE mindmap_id = ? AND user_id = ?",
                Integer.class, mindmapId, userId);
        if (userCount != null && userCount > 0) {
            return true;
        }

        // 检查角色共享
        LoginUser loginUser = (LoginUser) SecurityUtils.getSubject().getPrincipal();
        // 兼容不同版本的LoginUser类
        String rolesStr = "";
        try {
            // 尝试获取角色信息
            rolesStr = loginUser.getRoleCode() != null ? loginUser.getRoleCode() : "";
            if (rolesStr.isEmpty()) {
                // 尝试通过反射获取角色信息
                try {
                    Method getRoleCodes = loginUser.getClass().getMethod("getRoleCodes");
                    rolesStr = (String) getRoleCodes.invoke(loginUser);
                } catch (Exception e) {
                    log.warn("无法获取用户角色信息", e);
                }
            }
        } catch (Exception e) {
            log.warn("获取用户角色信息失败", e);
        }

        if (!rolesStr.isEmpty()) {
            List<String> roles = Arrays.asList(rolesStr.split(","));
            for (String roleId : roles) {
                Integer roleCount = jdbcTemplate.queryForObject(
                        "SELECT COUNT(*) FROM lq_mindmap_share WHERE mindmap_id = ? AND role_id = ?",
                        Integer.class, mindmapId, roleId);
                if (roleCount != null && roleCount > 0) {
                    return true;
                }
            }
        }

        return false;
    }

    @Transactional
    @Override
    public boolean rollbackVersion(String mindmapId, Integer version) {
        // 获取目标版本
        LqMindmapVersion targetVersion = versionMapper.selectOne(
                new QueryWrapper<LqMindmapVersion>()
                        .eq("mindmap_id", mindmapId)
                        .eq("version", version));

        if (targetVersion == null) {
            throw new RuntimeException("目标版本不存在");
        }

        // 重建目标版本内容
        String targetContent = rebuildContentFromVersions(mindmapId, version);

        // 更新主表
        LqMindmap mindmap = baseMapper.selectById(mindmapId);
        if (mindmap == null) {
            throw new RuntimeException("思维导图不存在");
        }

        // 创建新版本（回滚版本）
        Date now = new Date();
        LqMindmapVersion newVersion = new LqMindmapVersion();
        newVersion.setMindmapId(mindmapId);
        newVersion.setVersion(m mindmap.getLatestVersion() + 1);
        newVersion.setContentDiff(Base64.getEncoder().encodeToString(encryptContent(targetContent)));
        newVersion.setCreateTime(now);
        newVersion.setIsKeyVersion(true);
        newVersion.setRemark("回滚至版本 " + version);

        LoginUser loginUser = (LoginUser) SecurityUtils.getSubject().getPrincipal();
        newVersion.setUserId(loginUser.getUsername());
        newVersion.setTenantId(mindmap.getTenantId());

        versionMapper.insert(newVersion);

        // 更新主表内容
        mindmap.setContent(Base64.getEncoder().encodeToString(encryptContent(targetContent)));
        mindmap.setLatestVersion(newVersion.getVersion());
        mindmap.setUpdateTime(now);
       