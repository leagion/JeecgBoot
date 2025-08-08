package org.jeecg.modules.demo.lqQuhao.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.modules.demo.lqQuhao.entity.LqQuhao;
import org.jeecg.modules.demo.lqQuhao.mapper.LqQuhaoMapper;
import org.jeecg.modules.demo.lqQuhao.service.ILqQuhaoService;
import org.springframework.stereotype.Service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

/**
 * @Description: 文件取号
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Slf4j
@Service
public class LqQuhaoServiceImpl extends ServiceImpl<LqQuhaoMapper, LqQuhao> implements ILqQuhaoService {
    @Override
    public Integer getMaxChunum() {
        log.info("执行获取最大取号查询");

        // 使用 COALESCE 替代 IFNULL
        QueryWrapper<LqQuhao> queryWrapper = new QueryWrapper<>();
        queryWrapper.select("COALESCE(MAX(chunum), 0) as maxNum");
      //  log.info("SQL: {}", queryWrapper.getSqlSegment());

        // 使用 getObj 直接获取单个值
        Integer maxNum = this.baseMapper.selectObjs(queryWrapper).stream()
                .findFirst()
                .map(obj -> (Integer)obj)
                .orElse(0);

      //  log.info("查询结果: {}", maxNum);
        return maxNum;
    }

    @Override
    public Integer getMaxChunumByOrgCode(String sysOrgCode) {
      //  log.info("查询部门最大取号, sysOrgCode: {}", sysOrgCode);

        QueryWrapper<LqQuhao> queryWrapper = new QueryWrapper<>();
        queryWrapper.select("COALESCE(MAX(chunum), 0) as maxNum")
                .eq("sys_org_code", sysOrgCode);

      //  log.info("SQL查询条件: {}", queryWrapper.getSqlSegment());

        // 执行查询并处理结果
        Integer maxNum = this.baseMapper.selectObjs(queryWrapper)
                .stream()
                .findFirst()
                .map(obj -> (Integer)obj)
                .orElse(0);

     //   log.info("查询结果: {}", maxNum);
        return maxNum;
    }
    }
