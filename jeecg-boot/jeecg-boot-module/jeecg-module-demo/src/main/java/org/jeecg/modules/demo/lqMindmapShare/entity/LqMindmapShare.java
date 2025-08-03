package org.jeecg.modules.demo.lqMindmapShare.entity;

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
 * @Description: lq_mindmap_share
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Data
@TableName("lq_mindmap_share")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="lq_mindmap_share")
public class LqMindmapShare implements Serializable {
    private static final long serialVersionUID = 1L;

	/**主键*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "主键")
    private java.lang.String id;
	/**思维导图ID*/
	@Excel(name = "思维导图ID", width = 15)
    @Schema(description = "思维导图ID")
    private java.lang.String mindmapId;
	/**共享类型(user:用户, role:角色)*/
	@Excel(name = "共享类型(user:用户, role:角色)", width = 15)
    @Schema(description = "共享类型(user:用户, role:角色)")
    private java.lang.String shareType;
	/**共享目标ID*/
	@Excel(name = "共享目标ID", width = 15)
    @Schema(description = "共享目标ID")
    private java.lang.String shareTargetId;
	/**权限(view:查看, edit:编辑)*/
	@Excel(name = "权限(view:查看, edit:编辑)", width = 15)
    @Schema(description = "权限(view:查看, edit:编辑)")
    private java.lang.String permission;
	/**创建时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "创建时间")
    private java.util.Date createTime;
	/**创建人*/
    @Schema(description = "创建人")
    private java.lang.String createBy;
	/**租户ID*/
	@Excel(name = "租户ID", width = 15)
    @Schema(description = "租户ID")
    private java.lang.String tenantId;
}
