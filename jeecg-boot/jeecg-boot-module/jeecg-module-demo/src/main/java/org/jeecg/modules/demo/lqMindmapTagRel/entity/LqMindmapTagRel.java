package org.jeecg.modules.demo.lqMindmapTagRel.entity;

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
 * @Description: lq_mindmap_tag_rel
 * @Author: jeecg-boot
 * @Date:   2025-08-03
 * @Version: V1.0
 */
@Data
@TableName("lq_mindmap_tag_rel")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="lq_mindmap_tag_rel")
public class LqMindmapTagRel implements Serializable {
    private static final long serialVersionUID = 1L;

	/**主键*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "主键")
    private java.lang.String id;
	/**思维导图ID*/
	@Excel(name = "思维导图ID", width = 15)
    @Schema(description = "思维导图ID")
    private java.lang.String mindmapId;
	/**标签ID*/
	@Excel(name = "标签ID", width = 15)
    @Schema(description = "标签ID")
    private java.lang.String tagId;
	/**用户ID*/
	@Excel(name = "用户ID", width = 15)
    @Schema(description = "用户ID")
    private java.lang.String userId;
	/**租户ID*/
	@Excel(name = "租户ID", width = 15)
    @Schema(description = "租户ID")
    private java.lang.String tenantId;
    
    /**创建时间*/
    @JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Excel(name = "创建时间", width = 20, format = "yyyy-MM-dd HH:mm:ss")
    @Schema(description = "创建时间")
    private java.util.Date createTime;
}
