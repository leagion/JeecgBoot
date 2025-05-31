package org.jeecg.modules.demo.lqFocus.controller;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
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
	 @Operation(summary= "关注信息查询返回本周和上周的所有JSON数据")
	 @GetMapping("/getJsondataBy2Week")
	 public Map<String, String> getJsondata() {
		 List<List<String>> data = new ArrayList<>();

		 // 获取本周和上周的日期范围
		 Calendar calendar = Calendar.getInstance();
		 calendar.setFirstDayOfWeek(Calendar.MONDAY);

		 // 计算上周的日期范围
		 calendar.add(Calendar.WEEK_OF_YEAR, -1);
		 calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
		 calendar.set(Calendar.HOUR_OF_DAY, 0);
		 calendar.set(Calendar.MINUTE, 0);
		 calendar.set(Calendar.SECOND, 0);
		 calendar.set(Calendar.MILLISECOND, 0);
		 Date startOfLastWeek = calendar.getTime();

		 calendar.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
		 calendar.set(Calendar.HOUR_OF_DAY, 23);
		 calendar.set(Calendar.MINUTE, 59);
		 calendar.set(Calendar.SECOND, 59);
		 calendar.set(Calendar.MILLISECOND, 999);
		 Date endOfLastWeek = calendar.getTime();

		 // 查询上周的数据
		 QueryWrapper<LqFocus> lastWeekQueryWrapper = new QueryWrapper<>();
		 lastWeekQueryWrapper.between("create_time", startOfLastWeek, endOfLastWeek);
		 List<LqFocus> lastWeekFocuses = lqFocusService.list(lastWeekQueryWrapper);
		 data.addAll(processFocuses(lastWeekFocuses));

		 // 计算本周的日期范围
		 calendar.add(Calendar.WEEK_OF_YEAR, 1);
		 calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
		 calendar.set(Calendar.HOUR_OF_DAY, 0);
		 calendar.set(Calendar.MINUTE, 0);
		 calendar.set(Calendar.SECOND, 0);
		 calendar.set(Calendar.MILLISECOND, 0);
		 Date startOfThisWeek = calendar.getTime();

		 calendar.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
		 calendar.set(Calendar.HOUR_OF_DAY, 23);
		 calendar.set(Calendar.MINUTE, 59);
		 calendar.set(Calendar.SECOND, 59);
		 calendar.set(Calendar.MILLISECOND, 999);
		 Date endOfThisWeek = calendar.getTime();

		 // 查询本周的数据
		 QueryWrapper<LqFocus> thisWeekQueryWrapper = new QueryWrapper<>();
		 thisWeekQueryWrapper.between("create_time", startOfThisWeek, endOfThisWeek);
		 List<LqFocus> thisWeekFocuses = lqFocusService.list(thisWeekQueryWrapper);
		 data.addAll(processFocuses(thisWeekFocuses));

		 StringBuilder sb = new StringBuilder();
		 for (List<String> row : data) {
			 if (row.size() >= 2) {
				 String place = row.get(0);
				 String content = row.get(1);
				 String line = place + ": " + content;

				 // 对拼接后的行进行处理，超过18个字符换行
				 if (line.length() > 18) {
					 for (int i = 0; i < line.length(); i += 18) {
						 sb.append(line.substring(i, Math.min(i + 18, line.length()))).append("\n");
					 }
				 } else {
					 sb.append(line).append("\n\n");
				 }
			 }
		 }

		 // 构建最终结果
		 Map<String, String> result = new HashMap<>();
		 result.put("value", sb.toString());
		 return result;
	 }

	 @Operation(summary= "关注信息查询返回今日的所有JSON数据")
	 @GetMapping("/getJsondataByToday")
	 public Map<String, String> getJsondataByToday() {
		 // 获取今日的日期范围
		 LocalDateTime startOfToday = LocalDate.now().atStartOfDay();
		 LocalDateTime endOfToday = LocalDate.now().atTime(LocalTime.MAX);
		 Date startDate = Date.from(startOfToday.atZone(ZoneId.systemDefault()).toInstant());
		 Date endDate = Date.from(endOfToday.atZone(ZoneId.systemDefault()).toInstant());

		 // 查询今日的数据
		 QueryWrapper<LqFocus> todayQueryWrapper = new QueryWrapper<>();
		 todayQueryWrapper.between("create_time", startDate, endDate);
		 List<LqFocus> todayFocuses = lqFocusService.list(todayQueryWrapper);
		 List<List<String>> data = processFocuses(todayFocuses);

		 String resultString = formatData(data);

		 // 构建最终结果
		 Map<String, String> result = new HashMap<>();
		 result.put("value", resultString);
		 return result;
	 }
	 private String formatData(List<List<String>> data) {
		 StringBuilder sb = new StringBuilder();
		 for (List<String> row : data) {
			 if (row.size() >= 2) {
				 String place = row.get(0);
				 String content = row.get(1);
				 String line = place + ": " + content;

				 // 计算冒号及之前字符长度，用于后续对齐
				 int paddingLength = place.length() + 2;

				 // 按换行符分割内容
				 String[] lines = line.split("\n");
				 for (int i = 0; i < lines.length; i++) {
					 if (i > 0) {
						 // 非第一行添加对齐空格
						 for (int j = 0; j < paddingLength; j++) {
							 sb.append(" ");
						 }
					 }
					 sb.append(lines[i]).append("\n");
				 }
				 // 每个条目最后添加空行
				 sb.append("\n");
			 }
		 }
		 return sb.toString();
	 }

	 // 判断字符是否为标点符号（包括中文标点）
	 private static boolean isPunctuation(char c ) {
		 // 英文标点
		 if (c  == ',' || c == '.' || c  == '!' || c  == '?' || c  == ';' || c  == ':') {
			 return true;
		 }
		 // 中文标点
		 if (c  == '，' || c  == '。' || c  == '！' || c  == '？' || c  == '；' || c  == '：' || c  == '、' || c  == '“' || c  == '”' || c  == '‘' || c  == '’') {
			 return true;
		 }
		 return false;
	 }

	 private List<List<String>> processFocuses(List<LqFocus> focuses) {
		 List<List<String>> result = new ArrayList<>();
		 for (LqFocus focus : focuses) {
			 List<String> row = new ArrayList<>();
			 row.add(focus.getFocusplace());
			 row.add(focus.getFocuscontent());
			 result.add(row);
		 }
		 return result;
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
