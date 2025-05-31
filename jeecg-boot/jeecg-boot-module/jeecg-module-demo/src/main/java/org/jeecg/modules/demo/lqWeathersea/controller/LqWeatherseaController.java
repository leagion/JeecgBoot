package org.jeecg.modules.demo.lqWeathersea.controller;

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
import org.jeecg.modules.demo.lqWeathersea.entity.LqWeathersea;
import org.jeecg.modules.demo.lqWeathersea.service.ILqWeatherseaService;

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
 * @Description: 气象海况
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Tag(name="气象海况")
@RestController
@RequestMapping("/lqWeathersea/lqWeathersea")
@Slf4j
public class LqWeatherseaController extends JeecgController<LqWeathersea, ILqWeatherseaService> {
	@Autowired
	private ILqWeatherseaService lqWeatherseaService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqWeathersea
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "气象海况-分页列表查询")
	@Operation(summary="气象海况-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqWeathersea>> queryPageList(LqWeathersea lqWeathersea,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {
        QueryWrapper<LqWeathersea> queryWrapper = QueryGenerator.initQueryWrapper(lqWeathersea, req.getParameterMap());
		Page<LqWeathersea> page = new Page<LqWeathersea>(pageNo, pageSize);
		IPage<LqWeathersea> pageList = lqWeatherseaService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqWeathersea
	 * @return
	 */
	@AutoLog(value = "气象海况-添加")
	@Operation(summary="气象海况-添加")
	@RequiresPermissions("lqWeathersea:lq_weathersea:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqWeathersea lqWeathersea) {
		lqWeatherseaService.save(lqWeathersea);
		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqWeathersea
	 * @return
	 */
	@AutoLog(value = "气象海况-编辑")
	@Operation(summary="气象海况-编辑")
	@RequiresPermissions("lqWeathersea:lq_weathersea:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqWeathersea lqWeathersea) {
		lqWeatherseaService.updateById(lqWeathersea);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "气象海况-通过id删除")
	@Operation(summary="气象海况-通过id删除")
	@RequiresPermissions("lqWeathersea:lq_weathersea:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqWeatherseaService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "气象海况-批量删除")
	@Operation(summary="气象海况-批量删除")
	@RequiresPermissions("lqWeathersea:lq_weathersea:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqWeatherseaService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "气象海况-通过id查询")
	@Operation(summary="气象海况-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqWeathersea> queryById(@RequestParam(name="id",required=true) String id) {
		LqWeathersea lqWeathersea = lqWeatherseaService.getById(id);
		if(lqWeathersea==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqWeathersea);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqWeathersea
    */
    @RequiresPermissions("lqWeathersea:lq_weathersea:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqWeathersea lqWeathersea) {
        return super.exportXls(request, lqWeathersea, LqWeathersea.class, "气象海况");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqWeathersea:lq_weathersea:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqWeathersea.class);
    }

}
