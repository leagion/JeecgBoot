package org.jeecg.modules.demo.lqDuty.controller;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.jeecg.common.api.vo.Result;
import org.jeecg.common.system.query.QueryGenerator;
import org.jeecg.common.system.query.QueryRuleEnum;
import org.jeecg.common.util.oConvertUtils;
import org.jeecg.modules.demo.lqDuty.entity.LqDuty;
import org.jeecg.modules.demo.lqDuty.service.ILqDutyService;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.extern.slf4j.Slf4j;

import org.jeecgframework.poi.excel.ExcelImportUtil;
import org.jeecgframework.poi.excel.def.NormalExcelConstants;
import org.jeecgframework.poi.excel.entity.ExportParams;
import org.jeecgframework.poi.excel.entity.ImportParams;
import org.jeecgframework.poi.excel.view.JeecgEntityExcelView;
import org.jeecg.common.system.base.controller.JeecgController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;
import com.alibaba.fastjson.JSON;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import org.jeecg.common.aspect.annotation.AutoLog;
import org.apache.shiro.authz.annotation.RequiresPermissions;

 /**
 * @Description: 值班人员
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Tag(name="值班人员")
@RestController
@RequestMapping("/lqDuty/lqDuty")
@Slf4j
public class LqDutyController extends JeecgController<LqDuty, ILqDutyService> {
	@Autowired
	private ILqDutyService lqDutyService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqDuty
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "值班人员-分页列表查询")
	@Operation(summary="值班人员-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqDuty>> queryPageList(LqDuty lqDuty,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {
        // 自定义查询规则
        Map<String, QueryRuleEnum> customeRuleMap = new HashMap<>();
        // 自定义多选的查询规则为：LIKE_WITH_OR
        customeRuleMap.put("dutyunit", QueryRuleEnum.LIKE_WITH_OR);
        QueryWrapper<LqDuty> queryWrapper = QueryGenerator.initQueryWrapper(lqDuty, req.getParameterMap(),customeRuleMap);
		Page<LqDuty> page = new Page<LqDuty>(pageNo, pageSize);
		IPage<LqDuty> pageList = lqDutyService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqDuty
	 * @return
	 */
	@AutoLog(value = "值班人员-添加")
	@Operation(summary="值班人员-添加")
	@RequiresPermissions("lqDuty:lq_duty:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqDuty lqDuty) {
		lqDutyService.save(lqDuty);
		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqDuty
	 * @return
	 */
	@AutoLog(value = "值班人员-编辑")
	@Operation(summary="值班人员-编辑")
	@RequiresPermissions("lqDuty:lq_duty:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqDuty lqDuty) {
		lqDutyService.updateById(lqDuty);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "值班人员-通过id删除")
	@Operation(summary="值班人员-通过id删除")
	@RequiresPermissions("lqDuty:lq_duty:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqDutyService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "值班人员-批量删除")
	@Operation(summary="值班人员-批量删除")
	@RequiresPermissions("lqDuty:lq_duty:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqDutyService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "值班人员-通过id查询")
	@Operation(summary="值班人员-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqDuty> queryById(@RequestParam(name="id",required=true) String id) {
		LqDuty lqDuty = lqDutyService.getById(id);
		if(lqDuty==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqDuty);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqDuty
    */
    @RequiresPermissions("lqDuty:lq_duty:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqDuty lqDuty) {
        return super.exportXls(request, lqDuty, LqDuty.class, "值班人员");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqDuty:lq_duty:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqDuty.class);
    }

}
