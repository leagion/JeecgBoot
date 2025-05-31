package org.jeecg.modules.demo.lqPlan.controller;

import java.text.SimpleDateFormat;
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
import org.jeecg.modules.demo.lqPlan.entity.LqPlan;
import org.jeecg.modules.demo.lqPlan.entity.PercentageInfo;
import org.jeecg.modules.demo.lqPlan.entity.PlanInfo;
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


	 @Operation(summary = "查询今天（含今天）以前5天开始的计划，以及未来10天范围内有开始计划或者结束的计划信息并返回JSON数据")
	 @GetMapping("/getJsondataByDays")
	 public List<PlanInfo> getJsondata(@RequestParam(required = false, defaultValue = "10") int days) {
		 // 获取今天的日期
		 Calendar calendar = Calendar.getInstance();
		 calendar.set(Calendar.HOUR_OF_DAY, 0);
		 calendar.set(Calendar.MINUTE, 0);
		 calendar.set(Calendar.SECOND, 0);
		 calendar.set(Calendar.MILLISECOND, 0);
		 Date today = calendar.getTime();

		 // 计算今天以前5天的日期
		 Calendar pastCalendar = (Calendar) calendar.clone();
		 pastCalendar.add(Calendar.DAY_OF_YEAR, -5);
		 Date pastDate = pastCalendar.getTime();

		 // 计算未来10天的日期
		 Calendar futureCalendar = (Calendar) calendar.clone();
		 futureCalendar.add(Calendar.DAY_OF_YEAR, days);
		 futureCalendar.set(Calendar.HOUR_OF_DAY, 23);
		 futureCalendar.set(Calendar.MINUTE, 59);
		 futureCalendar.set(Calendar.SECOND, 59);
		 futureCalendar.set(Calendar.MILLISECOND, 999);
		 Date futureDate = futureCalendar.getTime();

		 SimpleDateFormat dateFormat = new SimpleDateFormat("MM.dd");

		 // 创建查询条件
		 QueryWrapper<LqPlan> queryWrapper = new QueryWrapper<>();
		 queryWrapper.and(wrapper -> wrapper
				 // 计划开始日期在过去5天到今天之间
				 .between("planstartdate", pastDate, today)
				 // 或者计划开始日期或结束日期在未来10天范围内
				 .or().between("planstartdate", today, futureDate)
				 .or().between("planenddate", today, futureDate)
				 // 或者任务内容包含“专项”
				 .or().like("missioncontent", "%专项%")
		 );

		 // 根据条件查询数据
		 List<LqPlan> latestPlans = lqPlanService.list(queryWrapper);

		 // 按照计划开始日期排序
		 latestPlans.sort(Comparator.comparing(LqPlan::getPlanstartdate));

		 List<PlanInfo> planInfoList = new ArrayList<>();
		 for (LqPlan plan : latestPlans) {
			 String startDate = dateFormat.format(plan.getPlanstartdate());
			 String endDate = dateFormat.format(plan.getPlanenddate());
			 String timeRange = startDate + " - " + endDate;

			 String place = plan.getMissionplace();
			 String person = plan.getMissionperson();
			 String vessel = plan.getMissionvessel();
			 String isAccept = plan.getIsaccept();
			 String content = plan.getMissioncontent();

			 PlanInfo planInfo = new PlanInfo(timeRange, place, person, vessel, isAccept, content);
			 planInfoList.add(planInfo);
		 }
		 return planInfoList;
	 }

	 @GetMapping("/getPercentageDataByDays")
	 @Operation(summary = "查询今天（含今天）以前5天开始的计划，以及未来10天范围内有结束的计划信息并返回JSON数据")
	 public List<PercentageInfo> getPercentageData(@RequestParam(required = false, defaultValue = "10") int days) {
		 // 获取今天的日期，将时间部分置为 00:00:00.000
		 Calendar calendar = Calendar.getInstance();
		 calendar.set(Calendar.HOUR_OF_DAY, 0);
		 calendar.set(Calendar.MINUTE, 0);
		 calendar.set(Calendar.SECOND, 0);
		 calendar.set(Calendar.MILLISECOND, 0);
		 Date today = calendar.getTime();
		 // 计算今天以前 5 天的日期
		 Calendar pastCalendar = (Calendar) calendar.clone();
		 pastCalendar.add(Calendar.DAY_OF_YEAR, -5);
		 Date pastDate = pastCalendar.getTime();
		 // 计算未来 10 天的日期，将时间部分置为 23:59:59.999
		 Calendar futureCalendar = (Calendar) calendar.clone();
		 futureCalendar.add(Calendar.DAY_OF_YEAR, days);
		 futureCalendar.set(Calendar.HOUR_OF_DAY, 23);
		 futureCalendar.set(Calendar.MINUTE, 59);
		 futureCalendar.set(Calendar.SECOND, 59);
		 futureCalendar.set(Calendar.MILLISECOND, 999);
		 Date futureDate = futureCalendar.getTime();
		 SimpleDateFormat dateFormat = new SimpleDateFormat("MM.dd");
		 // 创建查询条件
		 QueryWrapper<LqPlan> queryWrapper = new QueryWrapper<>();
		 queryWrapper.and(wrapper -> wrapper
				 // 计划开始日期在过去 5 天到今天之间，或者计划结束日期在未来 10 天范围内
				 .and(nested -> nested
						 .between("planstartdate", pastDate, today)
						 .or().between("planenddate", today, futureDate)
				 )
				 // 或者任务内容包含“专项”
				 .or().like("missioncontent", "%专项%")
		 );
		 // 根据条件查询数据
		 List<LqPlan> latestPlans = lqPlanService.list(queryWrapper);
		 // 过滤掉未开始的计划（计划开始日期晚于今天）
		 latestPlans = latestPlans.stream()
				 .filter(plan -> !plan.getPlanstartdate().after(today))
				 .collect(Collectors.toList());
		 return latestPlans.stream()
				 .map(plan -> {
					 String startDate = dateFormat.format(plan.getPlanstartdate());
					 String endDate = dateFormat.format(plan.getPlanenddate());
					 String name = plan.getMissionvessel() +"\n"+ "（" + startDate + "至" + endDate + "）";
					 // 计算整个任务期的天数
					 long totalDays = (plan.getPlanenddate().getTime() - plan.getPlanstartdate().getTime()) / (1000 * 60 * 60 * 24);
					 // 计算从计划开始日期到今天的天数
					 long daysPassed = (today.getTime() - plan.getPlanstartdate().getTime()) / (1000 * 60 * 60 * 24);
					 int percentage;
					 if (totalDays == 0) {
						 // 如果总天数为 0，认为任务已完成，百分比为 100
						 percentage = 100;
					 } else {
						 // 计算百分比并取整
						 percentage = (int) ((double) daysPassed / totalDays * 100);
						 // 确保百分比在 0 到 100 之间
						 percentage = Math.min(100, Math.max(0, percentage));
					 }
					 return new PercentageInfo(name, percentage);
				 })
				 .collect(Collectors.toList());
	 }

 }


