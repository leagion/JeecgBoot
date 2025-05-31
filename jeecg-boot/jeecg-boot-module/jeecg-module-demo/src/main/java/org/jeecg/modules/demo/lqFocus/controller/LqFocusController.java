package org.jeecg.modules.demo.lqFocus.controller;

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
import org.jeecg.modules.demo.lqFocus.entity.LqFocus;
import org.jeecg.modules.demo.lqFocus.service.ILqFocusService;

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
 * @Description: 重点关注
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Tag(name="重点关注")
@RestController
@RequestMapping("/lqFocus/lqFocus")
@Slf4j
public class LqFocusController extends JeecgController<LqFocus, ILqFocusService> {
	@Autowired
	private ILqFocusService lqFocusService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqFocus
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "重点关注-分页列表查询")
	@Operation(summary="重点关注-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqFocus>> queryPageList(LqFocus lqFocus,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {
        QueryWrapper<LqFocus> queryWrapper = QueryGenerator.initQueryWrapper(lqFocus, req.getParameterMap());
		Page<LqFocus> page = new Page<LqFocus>(pageNo, pageSize);
		IPage<LqFocus> pageList = lqFocusService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqFocus
	 * @return
	 */
	@AutoLog(value = "重点关注-添加")
	@Operation(summary="重点关注-添加")
	@RequiresPermissions("lqFocus:lq_focus:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqFocus lqFocus) {
		lqFocusService.save(lqFocus);
		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqFocus
	 * @return
	 */
	@AutoLog(value = "重点关注-编辑")
	@Operation(summary="重点关注-编辑")
	@RequiresPermissions("lqFocus:lq_focus:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqFocus lqFocus) {
		lqFocusService.updateById(lqFocus);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "重点关注-通过id删除")
	@Operation(summary="重点关注-通过id删除")
	@RequiresPermissions("lqFocus:lq_focus:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqFocusService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "重点关注-批量删除")
	@Operation(summary="重点关注-批量删除")
	@RequiresPermissions("lqFocus:lq_focus:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqFocusService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "重点关注-通过id查询")
	@Operation(summary="重点关注-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqFocus> queryById(@RequestParam(name="id",required=true) String id) {
		LqFocus lqFocus = lqFocusService.getById(id);
		if(lqFocus==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqFocus);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqFocus
    */
    @RequiresPermissions("lqFocus:lq_focus:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqFocus lqFocus) {
        return super.exportXls(request, lqFocus, LqFocus.class, "重点关注");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqFocus:lq_focus:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqFocus.class);
    }

}
