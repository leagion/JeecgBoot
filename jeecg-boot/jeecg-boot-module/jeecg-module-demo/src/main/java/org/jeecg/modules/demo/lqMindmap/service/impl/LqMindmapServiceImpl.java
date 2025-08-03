package org.jeecg.modules.demo.lqMindmap.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

import org.apache.shiro.SecurityUtils;
import org.jeecg.common.system.vo.LoginUser;
import org.jeecg.modules.demo.lqMindmapVersion.entity.LqMindmapVersion;
import org.jeecg.modules.demo.lqMindmapVersion.mapper.LqMindmapVersionMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.spec.KeySpec;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import org.jeecg.modules.demo.lqMindmap.entity.LqMindmap;
import org.jeecg.modules.demo.lqMindmap.mapper.LqMindmapMapper;
import org.jeecg.modules.demo.lqMindmap.service.ILqMindmapService;
import org.springframework.stereotype.Service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

/**
 * @Description: lq_mindmap
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Service
public class LqMindmapServiceImpl extends ServiceImpl<LqMindmapMapper, LqMindmap> implements ILqMindmapService {

    @Autowired
    private LqMindmapVersionMapper versionMapper;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 加密密钥（实际应用中应从配置文件获取）
    private static final String ENCRYPT_KEY = "liqiang_mindmap_key";

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
        // 加密内容
        byte[] encryptedContent = encryptContent(content);
        // 将byte[]转换为Base64编码的字符串存储
        mindmap.setContent(Base64.getEncoder().encodeToString(encryptedContent));

        // 获取当前用户ID
        String currentUserId = null;
        Object principal = SecurityUtils.getSubject().getPrincipal();
        if (principal != null) {
            currentUserId = ((LoginUser) principal).getId();
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
        return jdbcTemplate.queryForObject(sql, String.class, encryptedContent, ENCRYPT_KEY);
    }

    @Override
    public byte[] encryptContent(String content) {
        if (content == null) {
            return null;
        }
        // 实际应用中应使用PostgreSQL的pgp_sym_encrypt函数
        String sql = "SELECT pgp_sym_encrypt(?, ?)";
        return jdbcTemplate.queryForObject(sql, byte[].class, content, ENCRYPT_KEY);
    }

    /**
     * 清理旧版本，只保留最近50个版本，关键版本除外
     */
    private void cleanupOldVersions(String mindmapId) {
        // 查询所有版本
        QueryWrapper<LqMindmapVersion> queryWrapper = new QueryWrapper<>();
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
        // 实际应用中应使用jsondiffpatch等库计算JSON差异
        // 这里简化处理，直接存储新版本内容（后续步骤会优化）
        return newContent;
    }
}