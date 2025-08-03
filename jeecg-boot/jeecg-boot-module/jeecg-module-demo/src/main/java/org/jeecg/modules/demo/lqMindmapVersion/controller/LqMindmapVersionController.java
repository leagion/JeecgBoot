package org.jeecg.modules.demo.lqMindmapVersion.controller;

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
import org.jeecg.modules.demo.lqMindmapVersion.entity.LqMindmapVersion;
import org.jeecg.modules.demo.lqMindmapVersion.service.ILqMindmapVersionService;

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
 * @Description: lq_mindmap_version
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Tag(name="lq_mindmap_version")
@RestController
@RequestMapping("/lqMindmapVersion/lqMindmapVersion")
@Slf4j
public class LqMindmapVersionController extends JeecgController<LqMindmapVersion, ILqMindmapVersionService> {
	@Autowired
	private ILqMindmapVersionService lqMindmapVersionService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqMindmapVersion
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "lq_mindmap_version-分页列表查询")
	@Operation(summary="lq_mindmap_version-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqMindmapVersion>> queryPageList(LqMindmapVersion lqMindmapVersion,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {


        QueryWrapper<LqMindmapVersion> queryWrapper = QueryGenerator.initQueryWrapper(lqMindmapVersion, req.getParameterMap());
		Page<LqMindmapVersion> page = new Page<LqMindmapVersion>(pageNo, pageSize);
		IPage<LqMindmapVersion> pageList = lqMindmapVersionService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqMindmapVersion
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_version-添加")
	@Operation(summary="lq_mindmap_version-添加")
	@RequiresPermissions("lqMindmapVersion:lq_mindmap_version:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqMindmapVersion lqMindmapVersion) {
		lqMindmapVersionService.save(lqMindmapVersion);

		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqMindmapVersion
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_version-编辑")
	@Operation(summary="lq_mindmap_version-编辑")
	@RequiresPermissions("lqMindmapVersion:lq_mindmap_version:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqMindmapVersion lqMindmapVersion) {
		lqMindmapVersionService.updateById(lqMindmapVersion);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_version-通过id删除")
	@Operation(summary="lq_mindmap_version-通过id删除")
	@RequiresPermissions("lqMindmapVersion:lq_mindmap_version:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqMindmapVersionService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_version-批量删除")
	@Operation(summary="lq_mindmap_version-批量删除")
	@RequiresPermissions("lqMindmapVersion:lq_mindmap_version:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqMindmapVersionService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "lq_mindmap_version-通过id查询")
	@Operation(summary="lq_mindmap_version-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqMindmapVersion> queryById(@RequestParam(name="id",required=true) String id) {
		LqMindmapVersion lqMindmapVersion = lqMindmapVersionService.getById(id);
		if(lqMindmapVersion==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqMindmapVersion);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqMindmapVersion
    */
    @RequiresPermissions("lqMindmapVersion:lq_mindmap_version:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqMindmapVersion lqMindmapVersion) {
        return super.exportXls(request, lqMindmapVersion, LqMindmapVersion.class, "lq_mindmap_version");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqMindmapVersion:lq_mindmap_version:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqMindmapVersion.class);
    }

}
