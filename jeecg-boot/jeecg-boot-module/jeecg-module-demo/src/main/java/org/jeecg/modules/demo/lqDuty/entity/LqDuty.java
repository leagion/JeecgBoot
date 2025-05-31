package org.jeecg.modules.demo.lqDuty.entity;

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
 * @Description: 值班人员
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Data
@TableName("lq_duty")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="值班人员")
public class LqDuty implements Serializable {
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
	/**日期*/
	@Excel(name = "日期", width = 15, format = "yyyy-MM-dd")
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "日期")
    private java.util.Date dutyDate;
	/**单位*/
	@Excel(name = "单位", width = 15, dicCode = "unit_name")
	@Dict(dicCode = "unit_name")
    @Schema(description = "单位")
    private java.lang.String dutyunit;
	/**首长*/
	@Excel(name = "首长", width = 15)
    @Schema(description = "首长")
    private java.lang.String dutyofficer;
	/**处(科)长*/
	@Excel(name = "处(科)长", width = 15)
    @Schema(description = "处(科)长")
    private java.lang.String dutychief;
	/**综合计划*/
	@Excel(name = "综合计划", width = 15)
    @Schema(description = "综合计划")
    private java.lang.String comprehensiveplanning;
	/**wq行*/
	@Excel(name = "wq行", width = 15)
    @Schema(description = "wq行")
    private java.lang.String maritimedefenseaction;
	/**zf行*/
	@Excel(name = "zf行", width = 15)
    @Schema(description = "zf行")
    private java.lang.String lawenforcementaction;
	/**951*/
	@Excel(name = "951", width = 15)
    @Schema(description = "951")
    private java.lang.String policecall;
	/**qb*/
	@Excel(name = "qb", width = 15)
    @Schema(description = "qb")
    private java.lang.String intelligence;
	/**zg*/
	@Excel(name = "zg", width = 15)
    @Schema(description = "zg")
    private java.lang.String politicalaffairs;
	/**hz*/
	@Excel(name = "hz", width = 15)
    @Schema(description = "hz")
    private java.lang.String logisticsequipmentsupport;
	/**xt*/
	@Excel(name = "xt", width = 15)
    @Schema(description = "xt")
    private java.lang.String informationcommunication;
	/**jb*/
	@Excel(name = "jb", width = 15)
    @Schema(description = "jb")
    private java.lang.String technicalsupport;
	/**海气*/
	@Excel(name = "海气", width = 15)
    @Schema(description = "海气")
    private java.lang.String marinemeteorology;
	/**数据*/
	@Excel(name = "数据", width = 15)
    @Schema(description = "数据")
    private java.lang.String datasupport;
}
