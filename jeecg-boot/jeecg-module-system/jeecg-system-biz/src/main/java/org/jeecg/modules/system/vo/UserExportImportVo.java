package org.jeecg.modules.system.vo;

import lombok.Data;
import org.jeecgframework.poi.excel.annotation.Excel;

/**
 * @Description: 用户导出导入VO类（仅包含指定字段）
 * @author: jeecg-boot
 * @date: 2025/9/27
 */
@Data
public class UserExportImportVo {

    /**
     * 登录账号
     */
    @Excel(name = "登录账号", width = 15)
    private String username;

    /**
     * 真实姓名
     */
    @Excel(name = "真实姓名", width = 15)
    private String realname;

    /**
     * 座机号
     */
    @Excel(name = "座机号", width = 15)
    private String telephone;

    /**
     * 所属部门
     */
    @Excel(name = "所属部门", width = 15)
    private String departNames;

    /**
     * 角色
     */
    @Excel(name = "角色", width = 15)
    private String roleNames;

    /**
     * 手机号
     */
    @Excel(name = "手机号", width = 15)
    private String phone;

}