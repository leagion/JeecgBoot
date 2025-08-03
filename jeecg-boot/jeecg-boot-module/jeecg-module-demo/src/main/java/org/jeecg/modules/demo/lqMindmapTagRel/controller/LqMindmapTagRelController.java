package org.jeecg.modules.demo.lqMindmapTagRel.controller;

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
import org.jeecg.modules.demo.lqMindmapTagRel.entity.LqMindmapTagRel;
import org.jeecg.modules.demo.lqMindmapTagRel.service.ILqMindmapTagRelService;

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
 * @Description: lq_mindmap_tag_rel
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Tag(name="lq_mindmap_tag_rel")
@RestController
@RequestMapping("/lqMindmapTagRel/lqMindmapTagRel")
@Slf4j
public class LqMindmapTagRelController extends JeecgController<LqMindmapTagRel, ILqMindmapTagRelService> {
	@Autowired
	private ILqMindmapTagRelService lqMindmapTagRelService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqMindmapTagRel
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "lq_mindmap_tag_rel-分页列表查询")
	@Operation(summary="lq_mindmap_tag_rel-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqMindmapTagRel>> queryPageList(LqMindmapTagRel lqMindmapTagRel,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {


        QueryWrapper<LqMindmapTagRel> queryWrapper = QueryGenerator.initQueryWrapper(lqMindmapTagRel, req.getParameterMap());
		Page<LqMindmapTagRel> page = new Page<LqMindmapTagRel>(pageNo, pageSize);
		IPage<LqMindmapTagRel> pageList = lqMindmapTagRelService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqMindmapTagRel
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_tag_rel-添加")
	@Operation(summary="lq_mindmap_tag_rel-添加")
	@RequiresPermissions("lqMindmapTagRel:lq_mindmap_tag_rel:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqMindmapTagRel lqMindmapTagRel) {
		lqMindmapTagRelService.save(lqMindmapTagRel);

		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqMindmapTagRel
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_tag_rel-编辑")
	@Operation(summary="lq_mindmap_tag_rel-编辑")
	@RequiresPermissions("lqMindmapTagRel:lq_mindmap_tag_rel:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqMindmapTagRel lqMindmapTagRel) {
		lqMindmapTagRelService.updateById(lqMindmapTagRel);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_tag_rel-通过id删除")
	@Operation(summary="lq_mindmap_tag_rel-通过id删除")
	@RequiresPermissions("lqMindmapTagRel:lq_mindmap_tag_rel:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqMindmapTagRelService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_tag_rel-批量删除")
	@Operation(summary="lq_mindmap_tag_rel-批量删除")
	@RequiresPermissions("lqMindmapTagRel:lq_mindmap_tag_rel:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqMindmapTagRelService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "lq_mindmap_tag_rel-通过id查询")
	@Operation(summary="lq_mindmap_tag_rel-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqMindmapTagRel> queryById(@RequestParam(name="id",required=true) String id) {
		LqMindmapTagRel lqMindmapTagRel = lqMindmapTagRelService.getById(id);
		if(lqMindmapTagRel==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqMindmapTagRel);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqMindmapTagRel
    */
    @RequiresPermissions("lqMindmapTagRel:lq_mindmap_tag_rel:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqMindmapTagRel lqMindmapTagRel) {
        return super.exportXls(request, lqMindmapTagRel, LqMindmapTagRel.class, "lq_mindmap_tag_rel");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqMindmapTagRel:lq_mindmap_tag_rel:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqMindmapTagRel.class);
    }

}
