package org.jeecg.modules.demo.lqQuhao.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.jeecg.modules.demo.lqQuhao.entity.LqQuhao;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * @Description: 文件取号
 * @Author: jeecg-boot
 * @Date: 2025-05-31
 * @Version: V1.0
 */
public interface ILqQuhaoService extends IService<LqQuhao> {

  /**
   * 获取最大chunum
   * @return
   */
  Integer getMaxChunum();
  /**
   * 获取指定部门的最大取号
   * @param sysOrgCode 部门编码
   * @return 最大取号
   */
  Integer getMaxChunumByOrgCode(String sysOrgCode);
  
  /**
   * 获取指定部门和取号类型的最大取号
   * @param sysOrgCode 部门编码
   * @param numberType 取号类型
   * @return 最大取号
   */
  Integer getMaxChunumByOrgCodeAndType(String sysOrgCode, String numberType);
}