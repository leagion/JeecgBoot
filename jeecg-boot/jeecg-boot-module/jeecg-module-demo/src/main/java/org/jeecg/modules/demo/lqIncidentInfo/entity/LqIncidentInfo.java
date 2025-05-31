package org.jeecg.modules.demo.lqIncidentInfo.entity;

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
 * @Description: 专项应对
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Data
@TableName("lq_incident_info")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="专项应对")
public class LqIncidentInfo implements Serializable {
    private static final long serialVersionUID = 1L;

	/**序号*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "序号")
    private java.lang.String id;
	/**开始时间*/
	@Excel(name = "开始时间", width = 20, format = "yyyy-MM-dd HH:mm:ss")
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Schema(description = "开始时间")
    private java.util.Date startTime;
	/**结束时间*/
	@Excel(name = "结束时间", width = 20, format = "yyyy-MM-dd HH:mm:ss")
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Schema(description = "结束时间")
    private java.util.Date endTime;
	/**事发地*/
	@Excel(name = "事发地", width = 15, dicCode = "placeName")
	@Dict(dicCode = "placeName")
    @Schema(description = "事发地")
    private java.lang.String incidentLocation;
	/**船籍国*/
	@Excel(name = "船籍国", width = 15, dicCode = "countryName")
	@Dict(dicCode = "countryName")
    @Schema(description = "船籍国")
    private java.lang.String shipRegistrationCountry;
	/**船舷号*/
	@Excel(name = "船舷号", width = 15)
    @Schema(description = "船舷号")
    private java.lang.String shipNumber;
	/**事件经过*/
	@Excel(name = "事件经过", width = 15)
    @Schema(description = "事件经过")
    private java.lang.String incidentProcess;
	/**我方舷号*/
	@Excel(name = "我方舷号", width = 15)
    @Schema(description = "我方舷号")
    private java.lang.String ourShipNumber;
	/**备注*/
	@Excel(name = "备注", width = 15)
    @Schema(description = "备注")
    private java.lang.String remarks;
	/**填报人*/
	@Excel(name = "填报人", width = 15)
    @Schema(description = "填报人")
    private java.lang.String reporter;
}
