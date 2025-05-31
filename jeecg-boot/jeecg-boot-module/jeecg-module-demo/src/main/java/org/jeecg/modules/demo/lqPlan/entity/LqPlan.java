package org.jeecg.modules.demo.lqPlan.entity;

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
 * @Description: 重要计划
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Data
@TableName("lq_plan")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="重要计划")
public class LqPlan implements Serializable {
    private static final long serialVersionUID = 1L;

	/**序号*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "序号")
    private java.lang.String id;
	/**创建者*/
    @Schema(description = "创建者")
    private java.lang.String createBy;
	/**创建时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Schema(description = "创建时间")
    private java.util.Date createTime;
	/**更新者*/
    @Schema(description = "更新者")
    private java.lang.String updateBy;
	/**更新时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Schema(description = "更新时间")
    private java.util.Date updateTime;
	/**计划开始日期*/
	@Excel(name = "计划开始日期", width = 15, format = "yyyy-MM-dd")
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "计划开始日期")
    private java.util.Date planstartdate;
	/**计划结束日期*/
	@Excel(name = "计划结束日期", width = 15, format = "yyyy-MM-dd")
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "计划结束日期")
    private java.util.Date planenddate;
	/**任务点位*/
	@Excel(name = "任务点位", width = 15)
    @Schema(description = "任务点位")
    private java.lang.String missionplace;
	/**力力*/
	@Excel(name = "力力", width = 15)
    @Schema(description = "力力")
    private java.lang.String missionperson;
	/**号号*/
	@Excel(name = "号号", width = 15)
    @Schema(description = "号号")
    private java.lang.String missionvessel;
	/**是否批复*/
    @Excel(name = "是否批复", width = 15,replace = {"是_Y","否_N"} )
    @Schema(description = "是否批复")
    private java.lang.String isaccept;
	/**任务内容*/
	@Excel(name = "任务内容", width = 15)
    @Schema(description = "任务内容")
    private java.lang.String missioncontent;
}
