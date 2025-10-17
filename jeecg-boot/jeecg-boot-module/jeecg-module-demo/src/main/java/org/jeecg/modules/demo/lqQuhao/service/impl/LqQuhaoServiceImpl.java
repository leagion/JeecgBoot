package org.jeecg.modules.demo.lqQuhao.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.jeecg.modules.demo.lqQuhao.entity.LqQuhao;
import org.jeecg.modules.demo.lqQuhao.mapper.LqQuhaoMapper;
import org.jeecg.modules.demo.lqQuhao.service.ILqQuhaoService;
import org.springframework.stereotype.Service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

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
    /**
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
    **/
    @Override
    public Integer getMaxChunumByOrgCode(String sysOrgCode) {
        // 获取当前日期的年份（格式：yyyy）
        String currentYear = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy"));

        // 拼接查询条件：按部门代码和取号日期的年份查询最大编号
        QueryWrapper<LqQuhao> queryWrapper = new QueryWrapper<>();
        queryWrapper.select("COALESCE(MAX(chunum), 0) as maxNum")
                .eq("sys_org_code", sysOrgCode)
                .apply("datatime_quhao::text LIKE {0}", currentYear + "-%"); // 使用类型转换和参数绑定
// 匹配当前年份的取号记录（格式：yyyy-MM-dd）

        // 执行查询并返回结果
        return this.baseMapper.selectObjs(queryWrapper)
                .stream()
                .findFirst()
                .map(obj -> (Integer) obj)
                .orElse(0);
    }

    @Override
    public Integer getMaxChunumByOrgCodeAndType(String sysOrgCode, String numberType) {
        // 获取当前日期的年份（格式：yyyy）
        String currentYear = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy"));

        // 拼接查询条件：按部门代码、取号类型和取号日期的年份查询最大编号
        QueryWrapper<LqQuhao> queryWrapper = new QueryWrapper<>();
        queryWrapper.select("COALESCE(MAX(chunum), 0) as maxNum")
                .eq("sys_org_code", sysOrgCode)
                .eq("quhao_type", numberType)
                .apply("datatime_quhao::text LIKE {0}", currentYear + "-%"); // 匹配当前年份的取号记录

        // 执行查询并返回结果
        return this.baseMapper.selectObjs(queryWrapper)
                .stream()
                .findFirst()
                .map(obj -> (Integer) obj)
                .orElse(0);
    }

}
