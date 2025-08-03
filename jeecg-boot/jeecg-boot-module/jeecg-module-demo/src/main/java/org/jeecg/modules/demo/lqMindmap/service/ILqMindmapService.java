package org.jeecg.modules.demo.lqMindmap.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.jeecg.modules.demo.lqMindmap.entity.LqMindmap;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * @Description: lq_mindmap
 * @Author: jeecg-boot
 * @Date:   2025-08-03
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
}
