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
}