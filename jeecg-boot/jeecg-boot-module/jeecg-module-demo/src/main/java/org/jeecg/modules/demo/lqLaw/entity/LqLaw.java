package org.jeecg.modules.demo.lqLaw.entity;

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
 * @Description: 综合执法
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Data
@TableName("lq_law")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="综合执法")
public class LqLaw implements Serializable {
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
    private java.util.Date lawDate;
	/**单位*/
	@Excel(name = "单位", width = 15, dicCode = "unit_name")
	@Dict(dicCode = "unit_name")
    @Schema(description = "单位")
    private java.lang.String unitLaw;
	/**接处警数量*/
	@Excel(name = "接处警数量", width = 15)
    @Schema(description = "接处警数量")
    private java.lang.Integer numcalls;
	/**治安类数量*/
	@Excel(name = "治安类数量", width = 15)
    @Schema(description = "治安类数量")
    private java.lang.Integer criminal;
	/**渔业类数量*/
	@Excel(name = "渔业类数量", width = 15)
    @Schema(description = "渔业类数量")
    private java.lang.Integer incident;
	/**缉私类数量*/
	@Excel(name = "缉私类数量", width = 15)
    @Schema(description = "缉私类数量")
    private java.lang.Integer antismuggling;
	/**资源类数量*/
	@Excel(name = "资源类数量", width = 15)
    @Schema(description = "资源类数量")
    private java.lang.Integer marinefisheries;
	/**环境类数量*/
	@Excel(name = "环境类数量", width = 15)
    @Schema(description = "环境类数量")
    private java.lang.Integer marineresources;
	/**救援类数量*/
	@Excel(name = "救援类数量", width = 15)
    @Schema(description = "救援类数量")
    private java.lang.Integer marineecological;
	/**其他类数量*/
	@Excel(name = "其他类数量", width = 15)
    @Schema(description = "其他类数量")
    private java.lang.Integer foreignLaw;
	/**治安警情详情*/
	@Excel(name = "治安警情详情", width = 15)
    @Schema(description = "治安警情详情")
    private java.lang.String criminalList;
	/**渔业警情详情*/
	@Excel(name = "渔业警情详情", width = 15)
    @Schema(description = "渔业警情详情")
    private java.lang.String incidentList;
	/**缉私警情详情*/
	@Excel(name = "缉私警情详情", width = 15)
    @Schema(description = "缉私警情详情")
    private java.lang.String antismugglingList;
	/**资源警情详情*/
	@Excel(name = "资源警情详情", width = 15)
    @Schema(description = "资源警情详情")
    private java.lang.String marinefisheriesList;
	/**环境警情详情*/
	@Excel(name = "环境警情详情", width = 15)
    @Schema(description = "环境警情详情")
    private java.lang.String marineresourcesList;
	/**救援警情详情*/
	@Excel(name = "救援警情详情", width = 15)
    @Schema(description = "救援警情详情")
    private java.lang.String marineecologicalList;
	/**其他警情详情*/
	@Excel(name = "其他警情详情", width = 15)
    @Schema(description = "其他警情详情")
    private java.lang.String foreignLawList;
}
