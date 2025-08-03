package org.jeecg.modules.demo.lqMindmapAiCache.entity;

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
 * @Description: lq_mindmap_ai_cache
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Data
@TableName("lq_mindmap_ai_cache")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="lq_mindmap_ai_cache")
public class LqMindmapAiCache implements Serializable {
    private static final long serialVersionUID = 1L;

	/**主键*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "主键")
    private java.lang.String id;
	/**主题文本*/
	@Excel(name = "主题文本", width = 15)
    @Schema(description = "主题文本")
    private java.lang.String topicText;
	/**AI生成结果*/
	@Excel(name = "AI生成结果", width = 15)
    @Schema(description = "AI生成结果")
    private java.lang.String aiResult;
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
	/**命中次数*/
	@Excel(name = "命中次数", width = 15)
    @Schema(description = "命中次数")
    private java.lang.Integer hitCount;
	/**用户ID，为空表示公共缓存*/
	@Excel(name = "用户ID，为空表示公共缓存", width = 15)
    @Schema(description = "用户ID，为空表示公共缓存")
    private java.lang.String userId;
	/**租户ID*/
	@Excel(name = "租户ID", width = 15)
    @Schema(description = "租户ID")
    private java.lang.String tenantId;
}
