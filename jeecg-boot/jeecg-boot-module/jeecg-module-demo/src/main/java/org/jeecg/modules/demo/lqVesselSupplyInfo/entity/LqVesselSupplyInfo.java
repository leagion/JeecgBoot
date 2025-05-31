package org.jeecg.modules.demo.lqVesselSupplyInfo.entity;

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
 * @Description: 后装保障
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Data
@TableName("lq_vessel_supply_info")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="后装保障")
public class LqVesselSupplyInfo implements Serializable {
    private static final long serialVersionUID = 1L;

	/**序号*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "序号")
    private java.lang.String id;
	/**单位*/
	@Excel(name = "单位", width = 15)
    @Schema(description = "单位")
    private java.lang.String unit;
	/**填报时间*/
	@Excel(name = "填报时间", width = 15, format = "yyyy-MM-dd")
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "填报时间")
    private java.util.Date reportTime;
	/**舷号*/
	@Excel(name = "舷号", width = 15)
    @Schema(description = "舷号")
    private java.lang.String shipNumber;
	/**剩余燃油（吨）*/
	@Excel(name = "剩余燃油（吨）", width = 15)
    @Schema(description = "剩余燃油（吨）")
    private java.math.BigDecimal remainingFuel;
	/**剩余滑油（吨）*/
	@Excel(name = "剩余滑油（吨）", width = 15)
    @Schema(description = "剩余滑油（吨）")
    private java.math.BigDecimal remainingLubricatingOil;
	/**剩余淡水（吨）*/
	@Excel(name = "剩余淡水（吨）", width = 15)
    @Schema(description = "剩余淡水（吨）")
    private java.math.BigDecimal remainingFreshWater;
	/**剩余主食（天）*/
	@Excel(name = "剩余主食（天）", width = 15)
    @Schema(description = "剩余主食（天）")
    private java.lang.Integer remainingStapleFoodDays;
	/**剩余副食（天）*/
	@Excel(name = "剩余副食（天）", width = 15)
    @Schema(description = "剩余副食（天）")
    private java.lang.Integer remainingNonStapleFoodDays;
	/**影响任务安全故障*/
	@Excel(name = "影响任务安全故障", width = 15)
    @Schema(description = "影响任务安全故障")
    private java.lang.String safetyFault;
	/**燃油总容量（吨）*/
	@Excel(name = "燃油总容量（吨）", width = 15)
    @Schema(description = "燃油总容量（吨）")
    private java.math.BigDecimal fuelTotalCapacity;
	/**滑油总容量（吨）*/
	@Excel(name = "滑油总容量（吨）", width = 15)
    @Schema(description = "滑油总容量（吨）")
    private java.math.BigDecimal lubricatingOilTotalCapacity;
	/**淡水总容量（吨）*/
	@Excel(name = "淡水总容量（吨）", width = 15)
    @Schema(description = "淡水总容量（吨）")
    private java.math.BigDecimal freshWaterTotalCapacity;
	/**主食总量（天）*/
	@Excel(name = "主食总量（天）", width = 15)
    @Schema(description = "主食总量（天）")
    private java.lang.Integer stapleFoodTotalDays;
	/**副食总量（天）*/
	@Excel(name = "副食总量（天）", width = 15)
    @Schema(description = "副食总量（天）")
    private java.lang.Integer nonStapleFoodTotalDays;
	/**填报人*/
	@Excel(name = "填报人", width = 15)
    @Schema(description = "填报人")
    private java.lang.String reporter;
}
