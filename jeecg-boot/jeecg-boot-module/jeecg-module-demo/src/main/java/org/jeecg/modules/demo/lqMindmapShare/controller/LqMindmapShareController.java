package org.jeecg.modules.demo.lqMindmapShare.controller;

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
import org.jeecg.modules.demo.lqMindmapShare.entity.LqMindmapShare;
import org.jeecg.modules.demo.lqMindmapShare.service.ILqMindmapShareService;

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
 * @Description: lq_mindmap_share
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Tag(name="lq_mindmap_share")
@RestController
@RequestMapping("/lqMindmapShare/lqMindmapShare")
@Slf4j
public class LqMindmapShareController extends JeecgController<LqMindmapShare, ILqMindmapShareService> {
	@Autowired
	private ILqMindmapShareService lqMindmapShareService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqMindmapShare
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "lq_mindmap_share-分页列表查询")
	@Operation(summary="lq_mindmap_share-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqMindmapShare>> queryPageList(LqMindmapShare lqMindmapShare,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {


        QueryWrapper<LqMindmapShare> queryWrapper = QueryGenerator.initQueryWrapper(lqMindmapShare, req.getParameterMap());
		Page<LqMindmapShare> page = new Page<LqMindmapShare>(pageNo, pageSize);
		IPage<LqMindmapShare> pageList = lqMindmapShareService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqMindmapShare
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_share-添加")
	@Operation(summary="lq_mindmap_share-添加")
	@RequiresPermissions("lqMindmapShare:lq_mindmap_share:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqMindmapShare lqMindmapShare) {
		lqMindmapShareService.save(lqMindmapShare);

		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqMindmapShare
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_share-编辑")
	@Operation(summary="lq_mindmap_share-编辑")
	@RequiresPermissions("lqMindmapShare:lq_mindmap_share:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqMindmapShare lqMindmapShare) {
		lqMindmapShareService.updateById(lqMindmapShare);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_share-通过id删除")
	@Operation(summary="lq_mindmap_share-通过id删除")
	@RequiresPermissions("lqMindmapShare:lq_mindmap_share:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqMindmapShareService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_share-批量删除")
	@Operation(summary="lq_mindmap_share-批量删除")
	@RequiresPermissions("lqMindmapShare:lq_mindmap_share:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqMindmapShareService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "lq_mindmap_share-通过id查询")
	@Operation(summary="lq_mindmap_share-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqMindmapShare> queryById(@RequestParam(name="id",required=true) String id) {
		LqMindmapShare lqMindmapShare = lqMindmapShareService.getById(id);
		if(lqMindmapShare==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqMindmapShare);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqMindmapShare
    */
    @RequiresPermissions("lqMindmapShare:lq_mindmap_share:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqMindmapShare lqMindmapShare) {
        return super.exportXls(request, lqMindmapShare, LqMindmapShare.class, "lq_mindmap_share");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqMindmapShare:lq_mindmap_share:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqMindmapShare.class);
    }

}
