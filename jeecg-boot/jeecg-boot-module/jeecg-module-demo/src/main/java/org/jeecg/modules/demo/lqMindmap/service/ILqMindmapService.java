package org.jeecg.modules.demo.lqMindmap.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.jeecg.modules.demo.lqMindmap.entity.LqMindmap;
import org.jeecg.modules.demo.lqMindmapTagRel.entity.LqMindmapTagRel;
import org.jeecg.modules.demo.lqMindmapVersion.entity.LqMindmapVersion;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import java.util.List;
import java.util.Map;

/**
 * @Description: 思维导图
 * @Author: jeecg-boot
 * @Date:   2025-08-05
 * @Version: V1.0
 */
public interface ILqMindmapService extends IService<LqMindmap> {
    /**
     * 分页查询用户的思维导图
     */
    IPage<LqMindmap> queryUserMindmaps(Page<LqMindmap> page, String userId, String keyword);

    /**
     * 获取用户最新的思维导图
     */
    LqMindmap getLatestByUserId(String userId);

    /**
     * 保存思维导图（包含版本管理）
     */
    boolean saveMindmap(LqMindmap mindmap, String content, boolean isKeyVersion, String remark);

    /**
     * 解密获取内容
     */
    String decryptContent(byte[] encryptedContent);

    /**
     * 加密内容
     */
    byte[] encryptContent(String content);

    /**
     * 添加思维导图与标签的关联
     */
    boolean addTagRel(LqMindmapTagRel tagRel);

    /**
     * 移除思维导图与标签的关联
     */
    boolean removeTagRel(String mindmapId, String tagId);

    /**
     * 获取思维导图的版本列表
     */
    List<LqMindmapVersion> getVersionList(String mindmapId);

    /**
     * 获取思维导图的所有标签
     */
    List<Map<String, Object>> getMindmapTags(String mindmapId);

    /**
     * 比较两个版本
     */
    String compareVersions(String mindmapId, Integer version1, Integer version2);

    /**
     * 回滚到指定版本
     */
    boolean rollbackVersion(String mindmapId, Integer version);

    /**
     * 共享思维导图
     */
    boolean shareMindmap(String mindmapId, List<String> userIds, List<String> roleIds);

    /**
     * 检查共享权限
     */
    boolean checkSharePermission(String mindmapId, String userId);

    String rebuildContentFromVersions(String mindmapId);

    /**
     * 根据标签筛选思维导图
     * @param page 分页参数
     * @param userId 用户ID
     * @param tagId 标签ID
     * @param keyword 关键字
     * @return 思维导图分页列表
     */
    IPage<LqMindmap> queryMindmapsByTag(Page<LqMindmap> page, String userId, String tagId, String keyword);
}