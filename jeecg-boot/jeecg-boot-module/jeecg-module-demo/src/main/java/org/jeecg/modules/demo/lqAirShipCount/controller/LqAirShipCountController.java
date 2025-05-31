package org.jeecg.modules.demo.lqAirShipCount.controller;

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
import org.jeecg.modules.demo.lqAirShipCount.entity.FinalResultItem;
import org.jeecg.modules.demo.lqAirShipCount.entity.LqAirShipCount;
import org.jeecg.modules.demo.lqAirShipCount.service.ILqAirShipCountService;

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
import org.springframework.format.annotation.DateTimeFormat;
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
 * @Description: 舰机统计
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Tag(name="舰机统计")
@RestController
@RequestMapping("/lqAirShipCount/lqAirShipCount")
@Slf4j
public class LqAirShipCountController extends JeecgController<LqAirShipCount, ILqAirShipCountService> {
	@Autowired
	private ILqAirShipCountService lqAirShipCountService;
	 @Autowired
	 private DictService dictService;
	/**
	 * 分页列表查询
	 *
	 * @param lqAirShipCount
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "舰机统计-分页列表查询")
	@Operation(summary="舰机统计-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqAirShipCount>> queryPageList(LqAirShipCount lqAirShipCount,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {
        QueryWrapper<LqAirShipCount> queryWrapper = QueryGenerator.initQueryWrapper(lqAirShipCount, req.getParameterMap());
		Page<LqAirShipCount> page = new Page<LqAirShipCount>(pageNo, pageSize);
		IPage<LqAirShipCount> pageList = lqAirShipCountService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqAirShipCount
	 * @return
	 */
	@AutoLog(value = "舰机统计-添加")
	@Operation(summary="舰机统计-添加")
	@RequiresPermissions("lqAirShipCount:lq_air_ship_count:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqAirShipCount lqAirShipCount) {
		lqAirShipCountService.save(lqAirShipCount);
		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqAirShipCount
	 * @return
	 */
	@AutoLog(value = "舰机统计-编辑")
	@Operation(summary="舰机统计-编辑")
	@RequiresPermissions("lqAirShipCount:lq_air_ship_count:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqAirShipCount lqAirShipCount) {
		lqAirShipCountService.updateById(lqAirShipCount);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "舰机统计-通过id删除")
	@Operation(summary="舰机统计-通过id删除")
	@RequiresPermissions("lqAirShipCount:lq_air_ship_count:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqAirShipCountService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "舰机统计-批量删除")
	@Operation(summary="舰机统计-批量删除")
	@RequiresPermissions("lqAirShipCount:lq_air_ship_count:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqAirShipCountService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "舰机统计-通过id查询")
	@Operation(summary="舰机统计-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqAirShipCount> queryById(@RequestParam(name="id",required=true) String id) {
		LqAirShipCount lqAirShipCount = lqAirShipCountService.getById(id);
		if(lqAirShipCount==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqAirShipCount);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqAirShipCount
    */
    @RequiresPermissions("lqAirShipCount:lq_air_ship_count:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqAirShipCount lqAirShipCount) {
        return super.exportXls(request, lqAirShipCount, LqAirShipCount.class, "舰机统计");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqAirShipCount:lq_air_ship_count:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqAirShipCount.class);
    }

	 /**
	  * 按国家统计飞机和舰船数量
	  * @return 统计结果列表
	  */

	 @Operation(summary="查询当年舰船数输出JSON")
	 @GetMapping("/getJsonofAircraftShip")
	 public List<FinalResultItem> getJsonofAircraftShip(
			 @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date startDate,
			 @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date endDate) {
		 // 如果没有传入日期参数，默认查询当年累计数据
		 if (startDate == null || endDate == null) {
			 Calendar calendar = Calendar.getInstance();
			 calendar.set(Calendar.DAY_OF_YEAR, 1);
			 calendar.set(Calendar.HOUR_OF_DAY, 0);
			 calendar.set(Calendar.MINUTE, 0);
			 calendar.set(Calendar.SECOND, 0);
			 calendar.set(Calendar.MILLISECOND, 0);
			 startDate = calendar.getTime();
			 calendar.set(Calendar.DAY_OF_YEAR, calendar.getActualMaximum(Calendar.DAY_OF_YEAR));
			 calendar.set(Calendar.HOUR_OF_DAY, 23);
			 calendar.set(Calendar.MINUTE, 59);
			 calendar.set(Calendar.SECOND, 59);
			 calendar.set(Calendar.MILLISECOND, 999);
			 endDate = calendar.getTime();
		 }
		 // 创建查询条件
		 QueryWrapper<LqAirShipCount> queryWrapper = new QueryWrapper<>();
		 queryWrapper.between("incident_date", startDate, endDate);
		 // 查询指定日期范围内的数据
		 List<LqAirShipCount> allData = lqAirShipCountService.list(queryWrapper);
		 // 用于存储每个国家的统计结果
		 Map<String, Map<String, Integer>> resultMap = new HashMap<>();
		 // 遍历数据列表，进行统计
		 for (LqAirShipCount item : allData) {
			 String nationalityCode = item.getNationality();
			 Integer quantity = item.getQuantity();
			 String targetTypeCode = item.getTargetType();
			 if (nationalityCode != null && quantity != null && targetTypeCode != null) {
				 // 将国籍编码转换为国籍名称
				 String nationalityName = dictService.getDictTextByCodeAndValue("countryName", nationalityCode);
				 if (nationalityName == null) {
					 nationalityName = nationalityCode; // 如果转换失败，使用原编码
				 }

				 // 将目标类型编码转换为目标类型名称
				 String targetTypeName = dictService.getDictTextByCodeAndValue("targetType", targetTypeCode);
				 if (targetTypeName == null) {
					 if ("航空器".equals(targetTypeCode)) {
						 targetTypeName = "飞机";
					 } else if ("舰船".equals(targetTypeCode)) {
						 targetTypeName = "舰船";
					 } else {
						 targetTypeName = targetTypeCode; // 如果转换失败，使用原编码
					 }
				 }

				 resultMap.computeIfAbsent(nationalityName, k -> new HashMap<>())
						 .put(targetTypeName, resultMap.computeIfAbsent(nationalityName, k -> new HashMap<>())
								 .getOrDefault(targetTypeName, 0) + quantity);
			 }
		 }
		 // 将结果从 Map 转换为最终期望的列表结构
		 List<FinalResultItem> finalResultList = new ArrayList<>();
		 for (Map.Entry<String, Map<String, Integer>> entry : resultMap.entrySet()) {
			 String countryName = entry.getKey();
			 Map<String, Integer> typeCountMap = entry.getValue();
			 for (Map.Entry<String, Integer> typeEntry : typeCountMap.entrySet()) {
				 String type = typeEntry.getKey();
				 int value = typeEntry.getValue();
				 finalResultList.add(new FinalResultItem(countryName, value, type));
			 }
		 }
		 return finalResultList;
	 }
}
