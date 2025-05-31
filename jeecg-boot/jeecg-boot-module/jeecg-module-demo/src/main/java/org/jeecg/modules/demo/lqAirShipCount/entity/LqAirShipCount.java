package org.jeecg.modules.demo.lqAirShipCount.entity;

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
 * @Description: 舰机统计
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Data
@TableName("lq_air_ship_count")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="舰机统计")
public class LqAirShipCount implements Serializable {
    private static final long serialVersionUID = 1L;

	/**序号*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "序号")
    private java.lang.String id;
	/**日期*/
	@Excel(name = "日期", width = 15, format = "yyyy-MM-dd")
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "日期")
    private java.util.Date incidentDate;
	/**目标类型*/
	@Excel(name = "目标类型", width = 15, dicCode = "targetType")
	@Dict(dicCode = "targetType")
    @Schema(description = "目标类型")
    private java.lang.String targetType;
	/**国籍*/
	@Excel(name = "国籍", width = 15, dicCode = "countryName")
	@Dict(dicCode = "countryName")
    @Schema(description = "国籍")
    private java.lang.String nationality;
	/**数量*/
	@Excel(name = "数量", width = 15)
    @Schema(description = "数量")
    private java.lang.Integer quantity;
	/**舰机号*/
	@Excel(name = "舰机号", width = 15)
    @Schema(description = "舰机号")
    private java.lang.String shipAircraftNumber;
	/**活动区域*/
	@Excel(name = "活动区域", width = 15)
    @Schema(description = "活动区域")
    private java.lang.String activityArea;
	/**侵权情况*/
	@Excel(name = "侵权情况", width = 15)
    @Schema(description = "侵权情况")
    private java.lang.String infringementSituation;
	/**我应对情况*/
	@Excel(name = "我应对情况", width = 15)
    @Schema(description = "我应对情况")
    private java.lang.String ourResponse;
	/**备注*/
	@Excel(name = "备注", width = 15)
    @Schema(description = "备注")
    private java.lang.String remarks;
	/**填报人*/
	@Excel(name = "填报人", width = 15)
    @Schema(description = "填报人")
    private java.lang.String reporter;
}
