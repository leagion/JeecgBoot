package org.jeecg.modules.demo.lqWeathersea.entity;

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
 * @Description: 气象海况
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Data
@TableName("lq_weathersea")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="气象海况")
public class LqWeathersea implements Serializable {
    private static final long serialVersionUID = 1L;

	/**id*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "id")
    private java.lang.String id;
	/**记录时间*/
	@Excel(name = "记录时间", width = 20, format = "yyyy-MM-dd HH:mm:ss")
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Schema(description = "记录时间")
    private java.util.Date recordTime;
	/**海域*/
	@Excel(name = "海域", width = 15)
    @Schema(description = "海域")
    private java.lang.String location;
	/**天气(晴、雨）*/
	@Excel(name = "天气(晴、雨）", width = 15)
    @Schema(description = "天气(晴、雨）")
    private java.lang.String weather;
	/**风向*/
	@Excel(name = "风向", width = 15)
    @Schema(description = "风向")
    private java.lang.String windDirection;
	/**风级(几级)*/
	@Excel(name = "风级(几级)", width = 15)
    @Schema(description = "风级(几级)")
    private java.lang.Integer windScale;
	/**浪高(米)*/
	@Excel(name = "浪高(米)", width = 15)
    @Schema(description = "浪高(米)")
    private java.math.BigDecimal waveHeight;
	/**浪向*/
	@Excel(name = "浪向", width = 15)
    @Schema(description = "浪向")
    private java.lang.String waveDirection;
	/**海况(几级)*/
	@Excel(name = "海况(几级)", width = 15)
    @Schema(description = "海况(几级)")
    private java.lang.String seaCondition;
	/**能见度(海里)*/
	@Excel(name = "能见度(海里)", width = 15)
    @Schema(description = "能见度(海里)")
    private java.lang.Integer visibility;
	/**创建人*/
    @Schema(description = "创建人")
    private java.lang.String createBy;
	/**创建时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Schema(description = "创建时间")
    private java.util.Date createTime;
	/**更新人*/
    @Schema(description = "更新人")
    private java.lang.String updateBy;
	/**更新时间*/
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss")
    @Schema(description = "更新时间")
    private java.util.Date updateTime;
}
