package org.jeecg.modules.demo.lqMindmapTag.controller;

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
import org.jeecg.modules.demo.lqMindmapTag.entity.LqMindmapTag;
import org.jeecg.modules.demo.lqMindmapTag.service.ILqMindmapTagService;

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
 * @Description: lq_mindmap_tag
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Tag(name="lq_mindmap_tag")
@RestController
@RequestMapping("/lqMindmapTag/lqMindmapTag")
@Slf4j
public class LqMindmapTagController extends JeecgController<LqMindmapTag, ILqMindmapTagService> {
	@Autowired
	private ILqMindmapTagService lqMindmapTagService;
	
	/**
	 * 分页列表查询
	 *
	 * @param lqMindmapTag
	 * @param pageNo
	 * @param pageSize
	 * @param req
	 * @return
	 */
	//@AutoLog(value = "lq_mindmap_tag-分页列表查询")
	@Operation(summary="lq_mindmap_tag-分页列表查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqMindmapTag>> queryPageList(LqMindmapTag lqMindmapTag,
								   @RequestParam(name="pageNo", defaultValue="1") Integer pageNo,
								   @RequestParam(name="pageSize", defaultValue="10") Integer pageSize,
								   HttpServletRequest req) {


        QueryWrapper<LqMindmapTag> queryWrapper = QueryGenerator.initQueryWrapper(lqMindmapTag, req.getParameterMap());
		Page<LqMindmapTag> page = new Page<LqMindmapTag>(pageNo, pageSize);
		IPage<LqMindmapTag> pageList = lqMindmapTagService.page(page, queryWrapper);
		return Result.OK(pageList);
	}
	
	/**
	 *   添加
	 *
	 * @param lqMindmapTag
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_tag-添加")
	@Operation(summary="lq_mindmap_tag-添加")
	@RequiresPermissions("lqMindmapTag:lq_mindmap_tag:add")
	@PostMapping(value = "/add")
	public Result<String> add(@RequestBody LqMindmapTag lqMindmapTag) {
		lqMindmapTagService.save(lqMindmapTag);

		return Result.OK("添加成功！");
	}
	
	/**
	 *  编辑
	 *
	 * @param lqMindmapTag
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_tag-编辑")
	@Operation(summary="lq_mindmap_tag-编辑")
	@RequiresPermissions("lqMindmapTag:lq_mindmap_tag:edit")
	@RequestMapping(value = "/edit", method = {RequestMethod.PUT,RequestMethod.POST})
	public Result<String> edit(@RequestBody LqMindmapTag lqMindmapTag) {
		lqMindmapTagService.updateById(lqMindmapTag);
		return Result.OK("编辑成功!");
	}
	
	/**
	 *   通过id删除
	 *
	 * @param id
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_tag-通过id删除")
	@Operation(summary="lq_mindmap_tag-通过id删除")
	@RequiresPermissions("lqMindmapTag:lq_mindmap_tag:delete")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name="id",required=true) String id) {
		lqMindmapTagService.removeById(id);
		return Result.OK("删除成功!");
	}
	
	/**
	 *  批量删除
	 *
	 * @param ids
	 * @return
	 */
	@AutoLog(value = "lq_mindmap_tag-批量删除")
	@Operation(summary="lq_mindmap_tag-批量删除")
	@RequiresPermissions("lqMindmapTag:lq_mindmap_tag:deleteBatch")
	@DeleteMapping(value = "/deleteBatch")
	public Result<String> deleteBatch(@RequestParam(name="ids",required=true) String ids) {
		this.lqMindmapTagService.removeByIds(Arrays.asList(ids.split(",")));
		return Result.OK("批量删除成功!");
	}
	
	/**
	 * 通过id查询
	 *
	 * @param id
	 * @return
	 */
	//@AutoLog(value = "lq_mindmap_tag-通过id查询")
	@Operation(summary="lq_mindmap_tag-通过id查询")
	@GetMapping(value = "/queryById")
	public Result<LqMindmapTag> queryById(@RequestParam(name="id",required=true) String id) {
		LqMindmapTag lqMindmapTag = lqMindmapTagService.getById(id);
		if(lqMindmapTag==null) {
			return Result.error("未找到对应数据");
		}
		return Result.OK(lqMindmapTag);
	}

    /**
    * 导出excel
    *
    * @param request
    * @param lqMindmapTag
    */
    @RequiresPermissions("lqMindmapTag:lq_mindmap_tag:exportXls")
    @RequestMapping(value = "/exportXls")
    public ModelAndView exportXls(HttpServletRequest request, LqMindmapTag lqMindmapTag) {
        return super.exportXls(request, lqMindmapTag, LqMindmapTag.class, "lq_mindmap_tag");
    }

    /**
      * 通过excel导入数据
    *
    * @param request
    * @param response
    * @return
    */
    @RequiresPermissions("lqMindmapTag:lq_mindmap_tag:importExcel")
    @RequestMapping(value = "/importExcel", method = RequestMethod.POST)
    public Result<?> importExcel(HttpServletRequest request, HttpServletResponse response) {
        return super.importExcel(request, response, LqMindmapTag.class);
    }

}
