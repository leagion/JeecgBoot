package org.jeecg.modules.demo.lqQuhao.controller;

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
import org.jeecg.modules.demo.lqQuhao.entity.LqQuhao;
import org.jeecg.modules.demo.lqQuhao.service.ILqQuhaoService;

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
 * @Description: 文件取号
 * @Author: jeecg-boot
 * @Date: 2025-05-31
 * @Version: V1.0
 */
@Tag(name = "文件取号")
@RestController
@RequestMapping("/lqQuhao/lqQuhao")
@Slf4j
public class LqQuhaoController extends JeecgController<LqQuhao, ILqQuhaoService> {
	@Autowired
	private ILqQuhaoService lqQuhaoService;

	/**
	 * 分页列表查询
	 *
	 * @param lqQuhao
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	// @AutoLog(value = "文件取号-分页列表查询")
	@Operation(summary = "文件取号-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqQuhao>> queryPageList(LqQuhao lqQuhao,
			@RequestParam(name = "pageNo", defaultValue = "1") Integer pageNo,
			@RequestParam(name = "pageSize", defaultValue = "10") Integer pageSize,
			HttpServletRequest req) {
		// 自定义查询规则
		Map<String, QueryRuleEnum> customeRuleMap = new HashMap<>();
		// 自定义多选的查询规则为：LIKE_WITH_OR
		customeRuleMap.put("filetype", QueryRuleEnum.LIKE_WITH_OR);
		QueryWrapper<LqQuhao> queryWrapper = QueryGenerator.initQueryWrapper(lqQuhao, req.getParameterMap(),
				customeRuleMap);
		Page<LqQuhao> page = new Page<LqQuhao>(pageNo, pageSize);
		IPage<LqQuhao> pageList = lqQuhaoService.page(page, queryWrapper);
		return Result.OK(pageList);
	}

	/**
	 * 添加
	 *
	 * @param lqQuhao
	 * @return
	 */
	@AutoLog(value = "文件取号-添加")
	@Operation(summary = "文件取号-添加")
	@RequiresPermissions("lqQuhao:lq_quhao:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqQuhao lqQuhao) {
		lqQuhaoService.save(lqQuhao);
		return Result.OK("添加成功！");
	}

	/**
	 * 编辑
	 *
	 * @param lqQuhao
	 * @return
	 */
	@AutoLog(value = "文件取号-编辑")
	@Operation(summary = "文件取号-编辑")
	@RequiresPermissions("lqQuhao:lq_quhao:edit")
	@RequestMapping(value = "/edit", method = { RequestMethod.PUT, RequestMethod.POST })
	public Result<String> edit(@RequestBody LqQuhao lqQuhao) {
		lqQuhaoService.updateById(lqQuhao);
		return Result.OK("编辑成功!");
	}

	/**
	 * 通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "文件取号-通过id删除")
	@Operation(summary = "文件取号-通过id删除")
	@RequiresPermissions("lqQuhao:lq_quhao:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name = "id", required = true) String id) {
		lqQuhaoService.removeById(id);
		return Result.OK("删除成功!");
	}

	/**
	 * 批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "文件取号-批量删除")
	@Operation(summary = "文件取号-批量删除")
	@RequiresPermissions("lqQuhao:lq_quhao:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name = "ids", required = true) String ids) {
		this.lqQuhaoService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}

	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	// @AutoLog(value = "文件取号-通过id查询")
	@Operation(summary = "文件取号-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqQuhao> queryById(@RequestParam(name = "id", required = true) String id) {
		LqQuhao lqQuhao = lqQuhaoService.getById(id);
		if (lqQuhao == null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqQuhao);
	}

	/**
	 * 导出excel
	 *
	 * @param request
	 * @param lqQuhao
	 */
	@RequiresPermissions("lqQuhao:lq_quhao:exportXls")
	@RequestMapping(value = "/exportXls")
	public ModelAndView exportXls(HttpServletRequest request, LqQuhao lqQuhao) {
		return super.exportXls(request, lqQuhao, LqQuhao.class, "文件取号");
	}

	/**
	 * 通过excel导入数据
	 *
	 * @param request
	 * @param response
	 * @return
	 */
	@RequiresPermissions("lqQuhao:lq_quhao:importExcel")
	@RequestMapping(value = "/importExcel", method = RequestMethod.POST)
	public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
		return super.importExcel(request, response, LqQuhao.class);
	}

	@Operation(summary = "文件取号-查询最大值取号值")
	@GetMapping(value = "/maxChunum")
	public Result<Integer> getMaxChunum() {
		// 查询最大号
		QueryWrapper<LqQuhao> queryWrapper = new QueryWrapper<>();
		queryWrapper.select("max(chunum) as chunum");
		LqQuhao result = lqQuhaoService.getOne(queryWrapper, false);
		Integer maxNum = (result != null && result.getChunum() != null) ? result.getChunum() : 0;
		return Result.OK(maxNum);
	}

}
