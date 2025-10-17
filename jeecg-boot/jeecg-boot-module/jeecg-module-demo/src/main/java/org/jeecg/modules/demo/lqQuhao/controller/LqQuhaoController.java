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

import com.baomidou.mybatisplus.core.toolkit.StringUtils;
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
	/**
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
**/
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

		@GetMapping("/getMaxChunum")
		public Result<Integer> getMaxChunum() {
		//	log.info("开始获取最大取号");
			try {
				Integer maxNum = lqQuhaoService.getMaxChunum();
				//log.info("获取到的最大取号为: {}", maxNum);
				return Result.OK(maxNum);
			} catch (Exception e) {
			//	log.error("获取最大取号异常", e);
				return Result.error("获取最大取号失败：" + e.getMessage());
			}
		}



	/**
	 * 按部门编码获取最大取号
	 * @param sysOrgCode
	 * @return
	 */
	@GetMapping("/getMaxChunumByOrgCode")
	public Result<Integer> getMaxChunumByOrgCode(@RequestParam(name = "sysOrgCode") String sysOrgCode) {
	//	log.info("获取部门最大取号, sysOrgCode: {}", sysOrgCode);
		try {
			Integer maxNum = lqQuhaoService.getMaxChunumByOrgCode(sysOrgCode);
		//	log.info("部门最大取号: {}", maxNum);
			return Result.OK(maxNum);
		} catch (Exception e) {
			//log.error("获取部门最大取号失败", e);
			return Result.error("获取最大取号失败：" + e.getMessage());
		}
	}

	/**
	 * 按部门编码和取号类型获取最大取号
	 * @param sysOrgCode 部门编码
	 * @param numberType 取号类型
	 * @return
	 */
	@GetMapping("/getMaxChunumByOrgCodeAndType")
	public Result<Integer> getMaxChunumByOrgCodeAndType(
			@RequestParam(name = "sysOrgCode") String sysOrgCode,
			@RequestParam(name = "numberType") String numberType) {
		try {
			Integer maxNum = lqQuhaoService.getMaxChunumByOrgCodeAndType(sysOrgCode, numberType);
			return Result.OK(maxNum);
		} catch (Exception e) {
			return Result.error("获取最大取号失败：" + e.getMessage());
		}
	}

	/**
	 * 分页列表查询
	 * @param lqQuhao
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	@GetMapping("/list")
	public Result<IPage<LqQuhao>> queryPageList(LqQuhao lqQuhao,
												@RequestParam(name = "pageNo", defaultValue = "1") Integer pageNo,
												@RequestParam(name = "pageSize", defaultValue = "10") Integer pageSize,
												HttpServletRequest req) {
		// 添加部门编码过滤
		if (StringUtils.isNotBlank(lqQuhao.getSysOrgCode())) {
			QueryWrapper<LqQuhao> queryWrapper = QueryGenerator.initQueryWrapper(lqQuhao, req.getParameterMap());
			Page<LqQuhao> page = new Page<>(pageNo, pageSize);
			IPage<LqQuhao> pageList = lqQuhaoService.page(page, queryWrapper);
			return Result.OK(pageList);
		} else {
			return Result.error("缺少部门编码参数");
		}
	}
}