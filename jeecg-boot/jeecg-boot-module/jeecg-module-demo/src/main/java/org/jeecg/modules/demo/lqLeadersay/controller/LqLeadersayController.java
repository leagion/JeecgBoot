package org.jeecg.modules.demo.lqLeadersay.controller;

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
import org.jeecg.modules.demo.lqLeadersay.entity.LqLeadersay;
import org.jeecg.modules.demo.lqLeadersay.entity.ResultItemLeaderSay;
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

	 // 新增方法，返回自定义 JSON 结构
	 /**
	  * 生成并返回封装为 Map 格式的 JSON 数据
	  * @return 包含指定格式数据的 Result 对象
	  */
	 @Operation(summary="首长指示查询返回JSON")
	 @GetMapping("/getJsondata")
	 public List<List<String>> getJsondata() {
		 List<LqLeadersay> leadersayList = lqLeadersayService.list();
		 List<List<String>> data = new ArrayList<>();
		 SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		 for (LqLeadersay leadersay : leadersayList) {
			 List<String> row = new ArrayList<>();
			 if (leadersay.getSayDate() != null) {
				 row.add(dateFormat.format(leadersay.getSayDate()));
			 } else {
				 row.add("");
			 }
			 row.add(leadersay.getLeadername());
			 row.add(leadersay.getLeadersay());
			 data.add(row);
		 }
		 return data;
	 }


	 @Operation(summary="首长指示查询返回指定月份内的JSON数据")
	 @GetMapping("/getJsondataByMonth0")
	 public List<List<String>> getJsondata(@RequestParam(required = false, defaultValue = "6") int months) {
		 // 计算指定月份前的日期
		 Calendar calendar = Calendar.getInstance();
		 calendar.add(Calendar.MONTH, -months);
		 Date monthsAgo = calendar.getTime();

		 // 创建查询条件
		 QueryWrapper<LqLeadersay> queryWrapper = new QueryWrapper<>();
		 queryWrapper.ge("say_date", monthsAgo); // 大于等于指定月份前的日期

		 // 根据条件查询数据
		 List<LqLeadersay> leadersayList = lqLeadersayService.list(queryWrapper);

		 List<List<String>> data = new ArrayList<>();
		 SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM");
		 for (LqLeadersay leadersay : leadersayList) {
			 List<String> row = new ArrayList<>();
			 if (leadersay.getSayDate() != null) {
				 row.add(dateFormat.format(leadersay.getSayDate()));
			 } else {
				 row.add("");
			 }
			 row.add(leadersay.getLeadername());
			 row.add(leadersay.getLeadersay());
			 data.add(row);
		 }
		 return data;
	 }

	 @Operation(summary = "首长指示查询返回指定一周内的JSON数据")
	 @GetMapping("/getJsondataByWeek")
	 public List<ResultItemLeaderSay> getJsondataByWeek(@RequestParam(required = false, defaultValue = "3") int months) {
		 // 计算指定月份前的日期
		 Calendar calendar = Calendar.getInstance();
		 calendar.add(Calendar.MONTH, -months);
		 Date monthsAgo = calendar.getTime();

		 // 创建查询条件
		 QueryWrapper<LqLeadersay> queryWrapper = new QueryWrapper<>();
		 queryWrapper.ge("say_date", monthsAgo); // 大于等于指定月份前的日期

		 // 根据条件查询数据
		 List<LqLeadersay> leadersayList = lqLeadersayService.list(queryWrapper);

		 // 用于存储按周分组的数据
		 Map<String, List<String>> weeklyDataMap = new TreeMap<>();
		 SimpleDateFormat dateFormat = new SimpleDateFormat("MM.dd");

		 for (LqLeadersay leadersay : leadersayList) {
			 if (leadersay.getSayDate() != null) {
				 Calendar recordCalendar = Calendar.getInstance();
				 recordCalendar.setTime(leadersay.getSayDate());
				 // 设置一周的第一天为周一
				 recordCalendar.setFirstDayOfWeek(Calendar.MONDAY);
				 recordCalendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
				 Date startOfWeek = recordCalendar.getTime();
				 recordCalendar.add(Calendar.DAY_OF_WEEK, 6);
				 Date endOfWeek = recordCalendar.getTime();

				 // 格式化周的日期范围
				 String weekRange = dateFormat.format(startOfWeek) + "-" + dateFormat.format(endOfWeek);

				 // 拼接 leadername 和 leadersay
				 String combinedInfo = leadersay.getLeadername() + ": " + leadersay.getLeadersay();

				 // 将数据添加到对应的周分组中
				 weeklyDataMap.computeIfAbsent(weekRange, k -> new ArrayList<>()).add(combinedInfo);
			 }
		 }

		 // 整理最终结果
		 List<ResultItemLeaderSay> data = new ArrayList<>();
		 for (Map.Entry<String, List<String>> entry : weeklyDataMap.entrySet()) {
			 String weekRange = entry.getKey();
			 List<String> combinedInfos = entry.getValue();
			 for (String info : combinedInfos) {
				 data.add(new ResultItemLeaderSay(weekRange, info));
			 }
		 }

		 // 对结果进行排序
		 data.sort(Comparator.comparing(ResultItemLeaderSay::getYear));

		 return data;

	 }

	 @Operation(summary = "首长指示查询返回指定月份内按年月汇聚的JSON数据")
	 @GetMapping("/getJsondataByMonth")
	 public List<ResultItemLeaderSay> getJsondataByMonth(@RequestParam(required = false, defaultValue = "6") int months) {
		 // 计算指定月份前的日期
		 Calendar calendar = Calendar.getInstance();
		 calendar.add(Calendar.MONTH, -months);
		 Date monthsAgo = calendar.getTime();

		 // 创建查询条件
		 QueryWrapper<LqLeadersay> queryWrapper = new QueryWrapper<>();
		 queryWrapper.ge("say_date", monthsAgo); // 大于等于指定月份前的日期

		 // 根据条件查询数据
		 List<LqLeadersay> leadersayList = lqLeadersayService.list(queryWrapper);

		 // 用于存储按年月分组的数据
		 Map<String, List<String>> yearMonthDataMap = new TreeMap<>();
		 SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMM");

		 for (LqLeadersay leadersay : leadersayList) {
			 if (leadersay.getSayDate() != null) {
				 // 格式化日期为年月
				 String yearMonth = dateFormat.format(leadersay.getSayDate());

				 // 拼接 leadername 和 leadersay
				 String combinedInfo = leadersay.getLeadername() + ": " + leadersay.getLeadersay()+"\n";

				 // 将数据添加到对应的年月分组中
				 yearMonthDataMap.computeIfAbsent(yearMonth, k -> new ArrayList<>()).add(combinedInfo);
			 }
		 }

		 // 整理最终结果
		 List<ResultItemLeaderSay> data = new ArrayList<>();
		 for (Map.Entry<String, List<String>> entry : yearMonthDataMap.entrySet()) {
			 String yearMonth = entry.getKey();
			 List<String> combinedInfos = entry.getValue();
			 for (String info : combinedInfos) {
				 data.add(new ResultItemLeaderSay(yearMonth, info));
			 }
		 }

		 return data;
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
