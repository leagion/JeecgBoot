package org.jeecg.modules.demo.lqLeadersay.controller;

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
import org.jeecg.modules.demo.lqLeadersay.entity.LqLeadersay;
import org.jeecg.modules.demo.lqLeadersay.service.ILqLeadersayService;

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
 * @Description: 首长指示
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Tag(name="首长指示")
@RestController
@RequestMapping("/lqLeadersay/lqLeadersay")
@Slf4j
public class LqLeadersayController extends JeecgController<LqLeadersay, ILqLeadersayService> {
	@Autowired
	private ILqLeadersayService lqLeadersayService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqLeadersay
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "首长指示-分页列表查询")
	@Operation(summary="首长指示-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqLeadersay>> queryPageList(LqLeadersay lqLeadersay,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {
        QueryWrapper<LqLeadersay> queryWrapper = QueryGenerator.initQueryWrapper(lqLeadersay, req.getParameterMap());
		Page<LqLeadersay> page = new Page<LqLeadersay>(pageNo, pageSize);
		IPage<LqLeadersay> pageList = lqLeadersayService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqLeadersay
	 * @return
	 */
	@AutoLog(value = "首长指示-添加")
	@Operation(summary="首长指示-添加")
	@RequiresPermissions("lqLeadersay:lq_leadersay:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqLeadersay lqLeadersay) {
		lqLeadersayService.save(lqLeadersay);
		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqLeadersay
	 * @return
	 */
	@AutoLog(value = "首长指示-编辑")
	@Operation(summary="首长指示-编辑")
	@RequiresPermissions("lqLeadersay:lq_leadersay:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqLeadersay lqLeadersay) {
		lqLeadersayService.updateById(lqLeadersay);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "首长指示-通过id删除")
	@Operation(summary="首长指示-通过id删除")
	@RequiresPermissions("lqLeadersay:lq_leadersay:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqLeadersayService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "首长指示-批量删除")
	@Operation(summary="首长指示-批量删除")
	@RequiresPermissions("lqLeadersay:lq_leadersay:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqLeadersayService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "首长指示-通过id查询")
	@Operation(summary="首长指示-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqLeadersay> queryById(@RequestParam(name="id",required=true) String id) {
		LqLeadersay lqLeadersay = lqLeadersayService.getById(id);
		if(lqLeadersay==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqLeadersay);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqLeadersay
    */
    @RequiresPermissions("lqLeadersay:lq_leadersay:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqLeadersay lqLeadersay) {
        return super.exportXls(request, lqLeadersay, LqLeadersay.class, "首长指示");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqLeadersay:lq_leadersay:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqLeadersay.class);
    }

}
