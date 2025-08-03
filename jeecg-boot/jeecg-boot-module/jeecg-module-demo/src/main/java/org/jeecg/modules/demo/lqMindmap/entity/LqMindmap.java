package org.jeecg.modules.demo.lqMindmap.entity;

import java.io.Serializable;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.math.BigDecimal;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableLogic;
import org.jeecg.common.constant.ProvinceCityArea;
import org.jeecg.common.util.SpringContextUtils;
import lombok.Data;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.springframework.format.annotation.DateTimeFormat;
import org.jeecgframework.poi.excel.annotation.Excel;
import org.jeecg.common.aspect.annotation.Dict;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

/**
 * @Description: lq_mindmap
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Data
@TableName("lq_mindmap")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="lq_mindmap")
public class LqMindmap implements Serializable {
    private static final long serialVersionUID = 1L;

	/**主键*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "主键")
    private java.lang.String id;
	/**创建用户ID*/
	@Excel(name = "创建用户ID", width = 15)
    @Schema(description = "创建用户ID")
    private java.lang.String userId;
	/**思维导图名称*/
	@Excel(name = "思维导图名称", width = 15)
    @Schema(description = "思维导图名称")
    private java.lang.String name;
	/**思维导图内容（加密存储）*/
	@Excel(name = "思维导图内容（加密存储）", width = 15)
    @Schema(description = "思维导图内容（加密存储）")
    private java.lang.String content;
	/**创建时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "创建时间")
    private java.util.Date createTime;
	/**更新时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "更新时间")
    private java.util.Date updateTime;
	/**最新版本号*/
	@Excel(name = "最新版本号", width = 15)
    @Schema(description = "最新版本号")
    private java.lang.Integer latestVersion;
	/**是否共享*/
	@Excel(name = "是否共享", width = 15)
    @Schema(description = "是否共享")
    private java.lang.Boolean isShared;
	/**自动保存间隔(分钟)*/
	@Excel(name = "自动保存间隔(分钟)", width = 15)
    @Schema(description = "自动保存间隔(分钟)")
    private java.lang.Integer autoSaveInterval;
	/**所属部门*/
    @Schema(description = "所属部门")
    private java.lang.String sysOrgCode;
	/**租户ID*/
	@Excel(name = "租户ID", width = 15)
    @Schema(description = "租户ID")
    private java.lang.String tenantId;
}
