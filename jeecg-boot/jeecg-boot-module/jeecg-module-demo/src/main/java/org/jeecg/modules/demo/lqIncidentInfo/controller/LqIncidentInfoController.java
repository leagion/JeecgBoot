package org.jeecg.modules.demo.lqIncidentInfo.controller;

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
import org.jeecg.modules.demo.lqIncidentInfo.entity.LqIncidentInfo;
import org.jeecg.modules.demo.lqIncidentInfo.service.ILqIncidentInfoService;

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
 * @Description: 专项应对
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Tag(name="专项应对")
@RestController
@RequestMapping("/lqIncidentInfo/lqIncidentInfo")
@Slf4j
public class LqIncidentInfoController extends JeecgController<LqIncidentInfo, ILqIncidentInfoService> {
	@Autowired
	private ILqIncidentInfoService lqIncidentInfoService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqIncidentInfo
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "专项应对-分页列表查询")
	@Operation(summary="专项应对-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqIncidentInfo>> queryPageList(LqIncidentInfo lqIncidentInfo,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {
        QueryWrapper<LqIncidentInfo> queryWrapper = QueryGenerator.initQueryWrapper(lqIncidentInfo, req.getParameterMap());
		Page<LqIncidentInfo> page = new Page<LqIncidentInfo>(pageNo, pageSize);
		IPage<LqIncidentInfo> pageList = lqIncidentInfoService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqIncidentInfo
	 * @return
	 */
	@AutoLog(value = "专项应对-添加")
	@Operation(summary="专项应对-添加")
	@RequiresPermissions("lqIncidentInfo:lq_incident_info:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqIncidentInfo lqIncidentInfo) {
		lqIncidentInfoService.save(lqIncidentInfo);
		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqIncidentInfo
	 * @return
	 */
	@AutoLog(value = "专项应对-编辑")
	@Operation(summary="专项应对-编辑")
	@RequiresPermissions("lqIncidentInfo:lq_incident_info:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqIncidentInfo lqIncidentInfo) {
		lqIncidentInfoService.updateById(lqIncidentInfo);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "专项应对-通过id删除")
	@Operation(summary="专项应对-通过id删除")
	@RequiresPermissions("lqIncidentInfo:lq_incident_info:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqIncidentInfoService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "专项应对-批量删除")
	@Operation(summary="专项应对-批量删除")
	@RequiresPermissions("lqIncidentInfo:lq_incident_info:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqIncidentInfoService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "专项应对-通过id查询")
	@Operation(summary="专项应对-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqIncidentInfo> queryById(@RequestParam(name="id",required=true) String id) {
		LqIncidentInfo lqIncidentInfo = lqIncidentInfoService.getById(id);
		if(lqIncidentInfo==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqIncidentInfo);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqIncidentInfo
    */
    @RequiresPermissions("lqIncidentInfo:lq_incident_info:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqIncidentInfo lqIncidentInfo) {
        return super.exportXls(request, lqIncidentInfo, LqIncidentInfo.class, "专项应对");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqIncidentInfo:lq_incident_info:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqIncidentInfo.class);
    }

}
