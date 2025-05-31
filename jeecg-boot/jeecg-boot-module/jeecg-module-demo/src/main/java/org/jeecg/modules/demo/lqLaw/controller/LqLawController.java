package org.jeecg.modules.demo.lqLaw.controller;

import java.util.*;
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

import org.jeecg.modules.demo.lqUtils.DictService;
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
	 @Autowired
	 private DictService dictService;
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

	 // 定义 type 排序顺序的列表
	 private static final List<String> TYPE_ORDER = Arrays.asList("治安", "渔业", "缉私", "资源", "环境", "救援", "其他");
	 // 定义 name 排序顺序的列表
	 private static final List<String> NAME_ORDER = Arrays.asList("广东", "广西", "海南", "第三", "第四", "第五");

	 @Operation(summary = "综合执法查询返回指定月份内的JSON数据")
	 @GetMapping("/getJsondataByYear")
	 public List<Map<String, Object>> getJsondata() {
		 // 获取本年度 1 月 1 日的日期
		 Calendar calendar = Calendar.getInstance();
		 calendar.set(Calendar.MONTH, Calendar.JANUARY);
		 calendar.set(Calendar.DAY_OF_MONTH, 1);
		 calendar.set(Calendar.HOUR_OF_DAY, 0);
		 calendar.set(Calendar.MINUTE, 0);
		 calendar.set(Calendar.SECOND, 0);
		 calendar.set(Calendar.MILLISECOND, 0);
		 Date startDate = calendar.getTime();

		 // 创建查询条件
		 QueryWrapper<LqLaw> queryWrapper = new QueryWrapper<>();
		 queryWrapper.ge("law_date", startDate); // 大于等于本年度 1 月 1 日

		 // 根据条件查询数据
		 List<LqLaw> lqlawList = lqLawService.list(queryWrapper);

		 // 用于存储每种类型下每个单位的统计数据
		 Map<String, Map<String, Integer>> typeNameValueMap = new LinkedHashMap<>();

		 for (LqLaw lqLaw : lqlawList) {
			 // 获取单位编码
			 String unitCode = lqLaw.getUnitLaw();
			 // 将单位编码转换为单位名称
			 String unit = dictService.getDictTextByCodeAndValue("unit_name", unitCode);

			 // 处理治安警情数量
			 processData(typeNameValueMap, unit, lqLaw.getCriminal(), "治安");

			 // 处理渔业警情数量
			 processData(typeNameValueMap, unit, lqLaw.getIncident(), "渔业");

			 // 处理缉私警情数量
			 processData(typeNameValueMap, unit, lqLaw.getAntismuggling(), "缉私");

			 // 处理海洋资源警情数量
			 processData(typeNameValueMap, unit, lqLaw.getMarinefisheries(), "资源");

			 // 处理环境开发警情数量
			 processData(typeNameValueMap, unit, lqLaw.getMarineresources(), "环境");

			 // 处理海洋救援警情数量
			 processData(typeNameValueMap, unit, lqLaw.getMarineecological(), "救援");

			 // 处理其他警情数量
			 processData(typeNameValueMap, unit, lqLaw.getForeignLaw(), "其他");
		 }

		 List<Map<String, Object>> result = new ArrayList<>();
		 // 按照指定顺序生成最终结果
		 for (String type : TYPE_ORDER) {
			 Map<String, Integer> nameValueMap = typeNameValueMap.getOrDefault(type, new HashMap<>());
			 for (String name : NAME_ORDER) {
				 Integer value = nameValueMap.getOrDefault(name, 0);
				 Map<String, Object> dataMap = new HashMap<>();
				 dataMap.put("name", name);
				 dataMap.put("value", value);
				 dataMap.put("type", type);
				 result.add(dataMap);
			 }
		 }

		 return result;
	 }

	 private void processData(Map<String, Map<String, Integer>> typeNameValueMap, String name, Integer value, String type) {
		 if (value != null) {
			 typeNameValueMap.computeIfAbsent(type, k -> new HashMap<>())
					 .merge(name, value, Integer::sum);
		 }
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
