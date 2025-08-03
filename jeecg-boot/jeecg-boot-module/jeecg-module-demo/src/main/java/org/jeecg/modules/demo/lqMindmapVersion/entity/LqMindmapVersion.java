package org.jeecg.modules.demo.lqMindmapVersion.entity;

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
 * @Description: lq_mindmap_version
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Data
@TableName("lq_mindmap_version")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="lq_mindmap_version")
public class LqMindmapVersion implements Serializable {
    private static final long serialVersionUID = 1L;

	/**主键*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "主键")
    private java.lang.String id;
	/**关联思维导图ID*/
	@Excel(name = "关联思维导图ID", width = 15)
    @Schema(description = "关联思维导图ID")
    private java.lang.String mindmapId;
	/**版本号*/
	@Excel(name = "版本号", width = 15)
    @Schema(description = "版本号")
    private java.lang.Integer version;
	/**与上一版本的差异内容（加密存储）*/
	@Excel(name = "与上一版本的差异内容（加密存储）", width = 15)
    @Schema(description = "与上一版本的差异内容（加密存储）")
    private java.lang.String contentDiff;
	/**创建时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "创建时间")
    private java.util.Date createTime;
	/**是否为关键版本*/
	@Excel(name = "是否为关键版本", width = 15)
    @Schema(description = "是否为关键版本")
    private java.lang.Boolean isKeyVersion;
	/**版本备注*/
	@Excel(name = "版本备注", width = 15)
    @Schema(description = "版本备注")
    private java.lang.String remark;
	/**操作人ID*/
	@Excel(name = "操作人ID", width = 15)
    @Schema(description = "操作人ID")
    private java.lang.String userId;
	/**租户ID*/
	@Excel(name = "租户ID", width = 15)
    @Schema(description = "租户ID")
    private java.lang.String tenantId;
}
