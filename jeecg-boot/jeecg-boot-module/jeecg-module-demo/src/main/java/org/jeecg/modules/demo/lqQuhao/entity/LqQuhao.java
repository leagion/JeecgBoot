package org.jeecg.modules.demo.lqQuhao.entity;

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
 * @Description: 文件取号
 * @Author: jeecg-boot
 * @Date:   2025-05-31
 * @Version: V1.0
 */
@Data
@TableName("lq_quhao")
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = false)
@Schema(description="文件取号")
public class LqQuhao implements Serializable {
    private static final long serialVersionUID = 1L;

	/**是否办结*/
    @Excel(name = "是否办结", width = 15,replace = {"是_Y","否_N"} )
    @Schema(description = "是否办结")
    private java.lang.String returnfile;
	/**取号(数字）*/
	@Excel(name = "取号(数字）", width = 15)
    @Schema(description = "取号(数字）")
    private java.lang.Integer chunum;
	/**取号类型*/
	@Excel(name = "取号类型", width = 15, dicCode = "numberType")
	@Dict(dicCode = "numberType")
    @Schema(description = "取号类型")
    private java.lang.String numberType;
	/**日期时间*/
	@Excel(name = "日期时间", width = 15, format = "yyyy-MM-dd")
	@JsonFormat(timezone = "GMT+8",pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern="yyyy-MM-dd")
    @Schema(description = "日期时间")
    private java.util.Date datatimeQuhao;
	/**文件名称*/
	@Excel(name = "文件名称", width = 15)
    @Schema(description = "文件名称")
    private java.lang.String name;
	/**承办人*/
	@Excel(name = "承办人", width = 15)
    @Schema(description = "承办人")
    private java.lang.String dochandler;
	/**文件类型*/
	@Excel(name = "文件类型", width = 15, dicCode = "fileType")
	@Dict(dicCode = "fileType")
    @Schema(description = "文件类型")
    private java.lang.String filetype;
	/**主送单位*/
	@Excel(name = "主送单位", width = 15)
    @Schema(description = "主送单位")
    private java.lang.String primaryrecipient;
	/**抄送单位*/
	@Excel(name = "抄送单位", width = 15)
    @Schema(description = "抄送单位")
    private java.lang.String ccorganization;
	/**存储位置*/
	@Excel(name = "存储位置", width = 15)
    @Schema(description = "存储位置")
    private java.lang.String storagelocation;
	/**领导批示*/
	@Excel(name = "领导批示", width = 15)
    @Schema(description = "领导批示")
    private java.lang.String leaderinstructions;
	/**后续待办*/
	@Excel(name = "后续待办", width = 15)
    @Schema(description = "后续待办")
    private java.lang.String pendingactions;
	/**备注*/
	@Excel(name = "备注", width = 15)
    @Schema(description = "备注")
    private java.lang.String remark;
	/**文件上传*/
	@Excel(name = "文件上传", width = 15)
    private transient java.lang.String filescanString;

    private byte[] filescan;

    public byte[] getFilescan(){
        if(filescanString==null){
            return null;
        }
        try {
            return filescanString.getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return null;
    }

    public String getFilescanString(){
        if(filescan==null || filescan.length==0){
            return "";
        }
        try {
            return new String(filescan,"UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return "";
    }
	/**正式文件号*/
	@Excel(name = "正式文件号", width = 15)
    @Schema(description = "正式文件号")
    private java.lang.String filenum;
	/**序号*/
	@TableId(type = IdType.ASSIGN_ID)
    @Schema(description = "序号")
    private java.lang.String id;
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
	/**所属部门编码*/
    @Schema(description = "所属部门编码")
    private java.lang.String sysOrgCode;
}
