package org.jeecg.modules.demo.lqLaw.controller;

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
import org.jeecg.modules.demo.lqLaw.entity.LqLaw;
import org.jeecg.modules.demo.lqLaw.service.ILqLawService;

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
 * @Description: 综合执法
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Tag(name="综合执法")
@RestController
@RequestMapping("/lqLaw/lqLaw")
@Slf4j
public class LqLawController extends JeecgController<LqLaw, ILqLawService> {
	@Autowired
	private ILqLawService lqLawService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqLaw
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "综合执法-分页列表查询")
	@Operation(summary="综合执法-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqLaw>> queryPageList(LqLaw lqLaw,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {
        // 自定义查询规则
        Map<String, QueryRuleEnum> customeRuleMap = new HashMap<>();
        // 自定义多选的查询规则为：LIKE_WITH_OR
        customeRuleMap.put("unitLaw", QueryRuleEnum.LIKE_WITH_OR);
        QueryWrapper<LqLaw> queryWrapper = QueryGenerator.initQueryWrapper(lqLaw, req.getParameterMap(),customeRuleMap);
		Page<LqLaw> page = new Page<LqLaw>(pageNo, pageSize);
		IPage<LqLaw> pageList = lqLawService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqLaw
	 * @return
	 */
	@AutoLog(value = "综合执法-添加")
	@Operation(summary="综合执法-添加")
	@RequiresPermissions("lqLaw:lq_law:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqLaw lqLaw) {
		lqLawService.save(lqLaw);
		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqLaw
	 * @return
	 */
	@AutoLog(value = "综合执法-编辑")
	@Operation(summary="综合执法-编辑")
	@RequiresPermissions("lqLaw:lq_law:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqLaw lqLaw) {
		lqLawService.updateById(lqLaw);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "综合执法-通过id删除")
	@Operation(summary="综合执法-通过id删除")
	@RequiresPermissions("lqLaw:lq_law:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqLawService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "综合执法-批量删除")
	@Operation(summary="综合执法-批量删除")
	@RequiresPermissions("lqLaw:lq_law:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqLawService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "综合执法-通过id查询")
	@Operation(summary="综合执法-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqLaw> queryById(@RequestParam(name="id",required=true) String id) {
		LqLaw lqLaw = lqLawService.getById(id);
		if(lqLaw==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqLaw);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqLaw
    */
    @RequiresPermissions("lqLaw:lq_law:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqLaw lqLaw) {
        return super.exportXls(request, lqLaw, LqLaw.class, "综合执法");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqLaw:lq_law:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqLaw.class);
    }

}
