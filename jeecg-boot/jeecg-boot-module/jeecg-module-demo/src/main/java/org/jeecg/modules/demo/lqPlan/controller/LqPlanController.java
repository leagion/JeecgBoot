package org.jeecg.modules.demo.lqPlan.controller;

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
import org.jeecg.modules.demo.lqPlan.entity.LqPlan;
import org.jeecg.modules.demo.lqPlan.service.ILqPlanService;

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
 * @Description: 重要计划
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Tag(name="重要计划")
@RestController
@RequestMapping("/lqPlan/lqPlan")
@Slf4j
public class LqPlanController extends JeecgController<LqPlan, ILqPlanService> {
	@Autowired
	private ILqPlanService lqPlanService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqPlan
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "重要计划-分页列表查询")
	@Operation(summary="重要计划-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqPlan>> queryPageList(LqPlan lqPlan,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {
        QueryWrapper<LqPlan> queryWrapper = QueryGenerator.initQueryWrapper(lqPlan, req.getParameterMap());
		Page<LqPlan> page = new Page<LqPlan>(pageNo, pageSize);
		IPage<LqPlan> pageList = lqPlanService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqPlan
	 * @return
	 */
	@AutoLog(value = "重要计划-添加")
	@Operation(summary="重要计划-添加")
	@RequiresPermissions("lqPlan:lq_plan:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqPlan lqPlan) {
		lqPlanService.save(lqPlan);
		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqPlan
	 * @return
	 */
	@AutoLog(value = "重要计划-编辑")
	@Operation(summary="重要计划-编辑")
	@RequiresPermissions("lqPlan:lq_plan:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqPlan lqPlan) {
		lqPlanService.updateById(lqPlan);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "重要计划-通过id删除")
	@Operation(summary="重要计划-通过id删除")
	@RequiresPermissions("lqPlan:lq_plan:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqPlanService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "重要计划-批量删除")
	@Operation(summary="重要计划-批量删除")
	@RequiresPermissions("lqPlan:lq_plan:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqPlanService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "重要计划-通过id查询")
	@Operation(summary="重要计划-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqPlan> queryById(@RequestParam(name="id",required=true) String id) {
		LqPlan lqPlan = lqPlanService.getById(id);
		if(lqPlan==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqPlan);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqPlan
    */
    @RequiresPermissions("lqPlan:lq_plan:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqPlan lqPlan) {
        return super.exportXls(request, lqPlan, LqPlan.class, "重要计划");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqPlan:lq_plan:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqPlan.class);
    }

}
