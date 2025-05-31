package org.jeecg.modules.demo.lqVesselSupplyInfo.controller;

import java.math.BigDecimal;
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
import org.jeecg.modules.demo.lqVesselSupplyInfo.entity.LqVesselSupplyInfo;
import org.jeecg.modules.demo.lqVesselSupplyInfo.entity.ResultItem;
import org.jeecg.modules.demo.lqVesselSupplyInfo.service.ILqVesselSupplyInfoService;

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
 * @Description: 后装保障
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Tag(name="后装保障")
@RestController
@RequestMapping("/lqVesselSupplyInfo/lqVesselSupplyInfo")
@Slf4j
public class LqVesselSupplyInfoController extends JeecgController<LqVesselSupplyInfo, ILqVesselSupplyInfoService> {
	@Autowired
	private ILqVesselSupplyInfoService lqVesselSupplyInfoService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqVesselSupplyInfo
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "后装保障-分页列表查询")
	@Operation(summary="后装保障-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqVesselSupplyInfo>> queryPageList(LqVesselSupplyInfo lqVesselSupplyInfo,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {
        QueryWrapper<LqVesselSupplyInfo> queryWrapper = QueryGenerator.initQueryWrapper(lqVesselSupplyInfo, req.getParameterMap());
		Page<LqVesselSupplyInfo> page = new Page<LqVesselSupplyInfo>(pageNo, pageSize);
		IPage<LqVesselSupplyInfo> pageList = lqVesselSupplyInfoService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqVesselSupplyInfo
	 * @return
	 */
	@AutoLog(value = "后装保障-添加")
	@Operation(summary="后装保障-添加")
	@RequiresPermissions("lqVesselSupplyInfo:lq_vessel_supply_info:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqVesselSupplyInfo lqVesselSupplyInfo) {
		lqVesselSupplyInfoService.save(lqVesselSupplyInfo);
		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqVesselSupplyInfo
	 * @return
	 */
	@AutoLog(value = "后装保障-编辑")
	@Operation(summary="后装保障-编辑")
	@RequiresPermissions("lqVesselSupplyInfo:lq_vessel_supply_info:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqVesselSupplyInfo lqVesselSupplyInfo) {
		lqVesselSupplyInfoService.updateById(lqVesselSupplyInfo);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "后装保障-通过id删除")
	@Operation(summary="后装保障-通过id删除")
	@RequiresPermissions("lqVesselSupplyInfo:lq_vessel_supply_info:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqVesselSupplyInfoService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "后装保障-批量删除")
	@Operation(summary="后装保障-批量删除")
	@RequiresPermissions("lqVesselSupplyInfo:lq_vessel_supply_info:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqVesselSupplyInfoService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "后装保障-通过id查询")
	@Operation(summary="后装保障-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqVesselSupplyInfo> queryById(@RequestParam(name="id",required=true) String id) {
		LqVesselSupplyInfo lqVesselSupplyInfo = lqVesselSupplyInfoService.getById(id);
		if(lqVesselSupplyInfo==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqVesselSupplyInfo);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqVesselSupplyInfo
    */
    @RequiresPermissions("lqVesselSupplyInfo:lq_vessel_supply_info:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqVesselSupplyInfo lqVesselSupplyInfo) {
        return super.exportXls(request, lqVesselSupplyInfo, LqVesselSupplyInfo.class, "后装保障");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqVesselSupplyInfo:lq_vessel_supply_info:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqVesselSupplyInfo.class);
    }

	 @Operation(summary="查询补给量")
	 // 通用的数据查询逻辑
	 private List<LqVesselSupplyInfo> getTargetDataList() {
		 // 获取当天日期
		 Calendar calendar = Calendar.getInstance();
		 calendar.set(Calendar.HOUR_OF_DAY, 0);
		 calendar.set(Calendar.MINUTE, 0);
		 calendar.set(Calendar.SECOND, 0);
		 calendar.set(Calendar.MILLISECOND, 0);
		 Date todayStart = calendar.getTime();
		 calendar.set(Calendar.HOUR_OF_DAY, 23);
		 calendar.set(Calendar.MINUTE, 59);
		 calendar.set(Calendar.SECOND, 59);
		 calendar.set(Calendar.MILLISECOND, 999);
		 Date todayEnd = calendar.getTime();

		 // 查询当天的数据
		 QueryWrapper<LqVesselSupplyInfo> todayQueryWrapper = new QueryWrapper<>();
		 todayQueryWrapper.between("report_time", todayStart, todayEnd);
		 List<LqVesselSupplyInfo> todayDataList = lqVesselSupplyInfoService.list(todayQueryWrapper);
		 List<LqVesselSupplyInfo> targetDataList;
		 Map<String, LqVesselSupplyInfo> latestDataMap = new HashMap<>();

		 if (!todayDataList.isEmpty()) {
			 targetDataList = todayDataList;
		 } else {
			 // 如果当天没有数据，查询最近一天的数据
			 QueryWrapper<LqVesselSupplyInfo> latestQueryWrapper = new QueryWrapper<>();
			 latestQueryWrapper.orderByDesc("report_time");
			 List<LqVesselSupplyInfo> allData = lqVesselSupplyInfoService.list(latestQueryWrapper);
			 if (!allData.isEmpty()) {
				 Date latestDate = allData.get(0).getReportTime();
				 for (LqVesselSupplyInfo data : allData) {
					 if (data.getReportTime().equals(latestDate)) {
						 latestDataMap.put(data.getShipNumber(), data);
					 } else {
						 break;
					 }
				 }
				 targetDataList = new ArrayList<>(latestDataMap.values());
			 } else {
				 // 如果都没有数据，返回空列表
				 return new ArrayList<>();
			 }
		 }
		 return targetDataList;
	 }

	 // 计算天数差
	 private long calculateDayDifference(Date reportTime) {
		 Calendar calendar = Calendar.getInstance();
		 calendar.set(Calendar.HOUR_OF_DAY, 0);
		 calendar.set(Calendar.MINUTE, 0);
		 calendar.set(Calendar.SECOND, 0);
		 calendar.set(Calendar.MILLISECOND, 0);
		 Date todayStart = calendar.getTime();
		 return (todayStart.getTime() - reportTime.getTime()) / (1000 * 60 * 60 * 24);
	 }

	 // 查询主副食数据的 API 方法
	 @Operation(summary="查询主副食")
	 @GetMapping("/getStapleAndNonStapleFoodData")
	 public List<ResultItem> getStapleAndNonStapleFoodData() {
		 List<LqVesselSupplyInfo> targetDataList = getTargetDataList();
		 if (targetDataList.isEmpty()) {
			 return new ArrayList<>();
		 }
		 long dayDifference = calculateDayDifference(targetDataList.get(0).getReportTime());

		 List<ResultItem> foodResultList = new ArrayList<>();
		 for (LqVesselSupplyInfo targetData : targetDataList) {
			 String shipNumber = targetData.getShipNumber();

			 // 处理剩余主食
			 Integer remainingStapleFoodDays = targetData.getRemainingStapleFoodDays();
			 if (remainingStapleFoodDays != null) {
				 remainingStapleFoodDays = Math.max(0, remainingStapleFoodDays - (int) dayDifference);
				 foodResultList.add(new ResultItem(shipNumber, remainingStapleFoodDays, "主食"));
			 }

			 // 处理剩余副食
			 Integer remainingNonStapleFoodDays = targetData.getRemainingNonStapleFoodDays();
			 if (remainingNonStapleFoodDays != null) {
				 remainingNonStapleFoodDays = Math.max(0, remainingNonStapleFoodDays - (int) dayDifference);
				 foodResultList.add(new ResultItem(shipNumber, remainingNonStapleFoodDays, "副食"));
			 }
		 }
		 return foodResultList;
	 }

	 // 查询燃油数据的 API 方法
	 @Operation(summary="查询燃油数据")
	 @GetMapping("/getFuelData")
	 public List<ResultItem> getFuelData() {
		 List<LqVesselSupplyInfo> targetDataList = getTargetDataList();
		 if (targetDataList.isEmpty()) {
			 return new ArrayList<>();
		 }

		 List<ResultItem> fuelResultList = new ArrayList<>();
		 for (LqVesselSupplyInfo targetData : targetDataList) {
			 String shipNumber = targetData.getShipNumber();
			 BigDecimal remainingFuel = targetData.getRemainingFuel();
			 if (remainingFuel != null) {
				 fuelResultList.add(new ResultItem(shipNumber, remainingFuel.intValue(), "燃油"));
			 }
		 }
		 return fuelResultList;
	 }

}
