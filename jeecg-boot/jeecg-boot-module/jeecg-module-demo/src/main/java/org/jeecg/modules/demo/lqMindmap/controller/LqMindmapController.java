package org.jeecg.modules.demo.lqMindmap.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.jeecg.common.api.vo.Result;
import org.jeecg.common.aspect.annotation.AutoLog;
import org.jeecg.modules.demo.lqMindmap.entity.LqMindmap;
import org.jeecg.modules.demo.lqMindmap.service.ILqMindmapService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.apache.shiro.SecurityUtils;
import org.jeecg.common.system.vo.LoginUser;
import javax.servlet.http.HttpServletRequest;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

/**
 * @Description: 思维导图
 * @Author: jeecg-boot
 * @Date:   2025-08-05
 * @Version: V1.0
 */
@RestController
@RequestMapping("/lqMindmap/lqMindmap")
@Tag(name = "mindmap接口", description = "思维导图操作")
public class LqMindmapController {
	@Autowired
	private ILqMindmapService lqMindmapService;

	/**
	 * 分页查询
	 */
	@AutoLog(value = "思维导图-分页查询")
	@Operation(summary = "思维导图-分页查询", description = "思维导图-分页查询")
	@GetMapping(value = "/list")
	public Result<IPage<LqMindmap>> queryPageList(
			LqMindmap lqMindmap,
			@RequestParam(name = "pageNo", defaultValue = "1") Integer pageNo,
			@RequestParam(name = "pageSize", defaultValue = "10") Integer pageSize,
			HttpServletRequest req) {
		LoginUser loginUser = (LoginUser) SecurityUtils.getSubject().getPrincipal();
		String userId = loginUser.getId();
		Page<LqMindmap> page = new Page<>(pageNo, pageSize);
		IPage<LqMindmap> pageList = lqMindmapService.queryUserMindmaps(page, userId, req.getParameter("keyword"));
		return Result.OK(pageList);
	}

	/**
	 * 获取用户最新的思维导图
	 */
	@AutoLog(value = "获取用户最新的思维导图")
	@Operation(summary = "获取用户最新的思维导图", description = "获取用户最新的思维导图")
	@GetMapping(value = "/getLatest")
	public Result<Map<String, Object>> getLatest() {
		LoginUser loginUser = (LoginUser) SecurityUtils.getSubject().getPrincipal();
		String userId = loginUser.getId();
		LqMindmap mindmap = lqMindmapService.getLatestByUserId(userId);
		Map<String, Object> result = new HashMap<>();

		if (mindmap != null) {
			result.put("mindmap", mindmap);
			// 解密内容
			byte[] contentBytes = Base64.getDecoder().decode(mindmap.getContent());
			String content = lqMindmapService.decryptContent(contentBytes);
			result.put("content", content);
		}

		return Result.OK(result);
	}

	/**
	 * 获取单个思维导图详情
	 */
	@AutoLog(value = "思维导图-获取详情")
	@Operation(summary = "思维导图-获取详情", description = "思维导图-获取详情")
	@GetMapping(value = "/getById")
	public Result<Map<String, Object>> getById(@RequestParam(name = "id", required = true) String id) {
		LqMindmap mindmap = lqMindmapService.getById(id);
		if (mindmap == null) {
			return Result.error("未找到对应数据");
		}

		// 权限检查：只能查看自己的或共享的
		LoginUser loginUser = (LoginUser) SecurityUtils.getSubject().getPrincipal();
		String userId = loginUser.getId();
		if (!mindmap.getUserId().equals(userId)) {
			// TODO: 检查共享权限
			return Result.error("没有查看权限");
		}

		Map<String, Object> result = new HashMap<>();
		result.put("mindmap", mindmap);
		// 解密内容
		byte[] contentBytes = Base64.getDecoder().decode(mindmap.getContent());
		String content = lqMindmapService.decryptContent(contentBytes);
		result.put("content", content);

		return Result.OK(result);
	}

	/**
	 * 新增/编辑思维导图
	 */
	@AutoLog(value = "思维导图-保存")
	@Operation(summary = "思维导图-保存", description = "思维导图-保存")
	@PostMapping(value = "/save")
	public Result<String> save(
			@RequestBody Map<String, Object> params) {
		try {
			LqMindmap mindmap = new LqMindmap();
			if (params.containsKey("id") && params.get("id") != null && !params.get("id").toString().isEmpty()) {
				mindmap.setId(params.get("id").toString());
			}
			mindmap.setName(params.get("name").toString());
			
			LoginUser loginUser = (LoginUser) SecurityUtils.getSubject().getPrincipal();
			mindmap.setTenantId(loginUser.getRelTenantIds());
			mindmap.setSysOrgCode(loginUser.getOrgCode());

			// 处理自动保存间隔
			if (params.containsKey("autoSaveInterval")) {
				mindmap.setAutoSaveInterval(Integer.parseInt(params.get("autoSaveInterval").toString()));
			}

			String content = params.get("content").toString();
			boolean isKeyVersion = params.containsKey("isKeyVersion") && (boolean) params.get("isKeyVersion");
			String remark = params.containsKey("remark") ? params.get("remark").toString() : null;

			lqMindmapService.saveMindmap(mindmap, content, isKeyVersion, remark);
			return Result.OK("保存成功", mindmap.getId());
		} catch (Exception e) {
			e.printStackTrace();
			return Result.error("保存失败: " + e.getMessage());
		}
	}

	/**
	 * 删除思维导图
	 */
	@AutoLog(value = "思维导图-删除")
	@Operation(summary = "思维导图-删除", description = "思维导图-删除")
	@DeleteMapping(value = "/delete")
	public Result<String> delete(@RequestParam(name = "id", required = true) String id) {
		// 权限检查
		LqMindmap mindmap = lqMindmapService.getById(id);
		if (mindmap == null) {
			return Result.error("未找到对应数据");
		}

		LoginUser loginUser = (LoginUser) SecurityUtils.getSubject().getPrincipal();
		String userId = loginUser.getId();
		if (!mindmap.getUserId().equals(userId)) {
			return Result.error("没有删除权限");
		}

		lqMindmapService.removeById(id);
		// TODO: 同时删除关联的版本记录
		return Result.OK("删除成功");
	}
}