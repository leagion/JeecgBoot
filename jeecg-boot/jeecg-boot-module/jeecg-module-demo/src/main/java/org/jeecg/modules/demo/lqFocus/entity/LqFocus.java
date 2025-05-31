package org.jeecg.modules.demo.lqFocus.entity;

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
 * @Description: 重点关注
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Data
@TableName("lq_focus")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="重点关注")
public class LqFocus implements Serializable {
    private static final long serialVersionUID = 1L;

	/**序号*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "序号")
    private java.lang.String id;
	/**创建者*/
    @Schema(description = "创建者")
    private java.lang.String createBy;
	/**时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Schema(description = "时间")
    private java.util.Date createTime;
	/**更新者*/
    @Schema(description = "更新者")
    private java.lang.String updateBy;
	/**更新时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Schema(description = "更新时间")
    private java.util.Date updateTime;
	/**地点*/
	@Excel(name = "地点", width = 15)
    @Schema(description = "地点")
    private java.lang.String focusplace;
	/**关注内容*/
	@Excel(name = "关注内容", width = 15)
    @Schema(description = "关注内容")
    private java.lang.String focuscontent;
}
