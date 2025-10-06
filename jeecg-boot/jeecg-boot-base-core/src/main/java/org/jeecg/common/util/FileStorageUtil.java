package org.jeecg.common.util;

import lombok.extern.slf4j.Slf4j;
import org.jeecg.common.constant.CommonConstant;
import org.jeecg.common.util.oss.OssBootUtil;
import org.jeecg.common.util.MinioUtil;
import org.jeecg.common.util.CommonUtils;
import org.jeecg.common.util.oConvertUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.Date;

/**
 * 全局文件存储工具类
 * 统一管理文件操作，根据配置选择使用MinIO或OSS
 * 
 * @author: jeecg-boot
 */
@Slf4j
public class FileStorageUtil {

    /**
     * 在线图片上传
     * 
     * @param data       图片数据
     * @param basePath   基础路径
     * @param bizPath    业务路径
     * @param uploadType 上传类型
     * @return 文件URL
     */
    public static String uploadOnlineImage(byte[] data, String basePath, String bizPath, String uploadType) {
        try {
            if (CommonConstant.UPLOAD_TYPE_MINIO.equals(uploadType)) {
                // MinioUtil上传处理
                InputStream in = new ByteArrayInputStream(data);
                String fileName = "image" + Math.round(Math.random() * 100000000000L);
                fileName += "." + getFileExtendName(data);
                String relativePath = bizPath + "/" + fileName;
                return MinioUtil.upload(in, relativePath);
            } else if (CommonConstant.UPLOAD_TYPE_OSS.equals(uploadType)) {
                // OSS上传处理
                return CommonUtils.uploadOnlineImage(data, basePath, bizPath, uploadType);
            } else {
                // 本地存储处理
                return CommonUtils.uploadOnlineImage(data, basePath, bizPath, uploadType);
            }
        } catch (Exception e) {
            log.error("在线图片上传失败: {}", e.getMessage(), e);
            throw new RuntimeException("在线图片上传失败", e);
        }
    }

    /**
     * 获取文件扩展名
     * 
     * @param data 文件数据
     * @return 扩展名
     */
    private static String getFileExtendName(byte[] data) {
        if (data == null || data.length < 12) {
            return "jpg";
        }
        // 简单的文件类型判断
        if (data[0] == (byte) 0xFF && data[1] == (byte) 0xD8) {
            return "jpg";
        } else if (data[0] == (byte) 0x89 && data[1] == (byte) 0x50 && data[2] == (byte) 0x4E && data[3] == (byte) 0x47) {
            return "png";
        } else if (data[0] == (byte) 0x47 && data[1] == (byte) 0x49 && data[2] == (byte) 0x46 && data[3] == (byte) 0x38) {
            return "gif";
        } else if (data[0] == (byte) 0x52 && data[1] == (byte) 0x49 && data[2] == (byte) 0x46 && data[3] == (byte) 0x46) {
            return "webp";
        }
        return "jpg"; // 默认返回jpg
    }

    /**
     * 上传文件
     * 
     * @param file       文件对象
     * @param bizPath    业务路径
     * @param uploadType 上传类型
     * @return 文件URL
     */
    public static String upload(MultipartFile file, String bizPath, String uploadType) {
        try {
            if (CommonConstant.UPLOAD_TYPE_MINIO.equals(uploadType)) {
                return MinioUtil.upload(file, bizPath);
            } else if (CommonConstant.UPLOAD_TYPE_OSS.equals(uploadType)) {
                return OssBootUtil.upload(file, bizPath);
            } else {
                // 默认为本地存储，调用CommonUtils的upload方法处理
                return CommonUtils.upload(file, bizPath, uploadType);
            }
        } catch (Exception e) {
            log.error("文件上传失败: {}", e.getMessage(), e);
            throw new RuntimeException("文件上传失败", e);
        }
    }

    /**
     * 上传文件（带自定义桶）
     * 
     * @param file         文件对象
     * @param bizPath      业务路径
     * @param uploadType   上传类型
     * @param customBucket 自定义桶名
     * @return 文件URL
     */
    public static String upload(MultipartFile file, String bizPath, String uploadType, String customBucket) {
        try {
            if (CommonConstant.UPLOAD_TYPE_MINIO.equals(uploadType)) {
                return MinioUtil.upload(file, bizPath, customBucket);
            } else if (CommonConstant.UPLOAD_TYPE_OSS.equals(uploadType)) {
                return OssBootUtil.upload(file, bizPath, customBucket);
            } else {
                // 默认为本地存储，调用CommonUtils的upload方法处理
                return CommonUtils.upload(file, bizPath, uploadType);
            }
        } catch (Exception e) {
            log.error("文件上传失败: {}", e.getMessage(), e);
            throw new RuntimeException("文件上传失败", e);
        }
    }

    /**
     * 上传输入流
     * 
     * @param inputStream  输入流
     * @param relativePath 相对路径
     * @param uploadType   上传类型
     * @return 文件URL
     */
    public static String upload(InputStream inputStream, String relativePath, String uploadType) {
        try {
            if (CommonConstant.UPLOAD_TYPE_MINIO.equals(uploadType)) {
                return MinioUtil.upload(inputStream, relativePath);
            } else if (CommonConstant.UPLOAD_TYPE_OSS.equals(uploadType)) {
                return OssBootUtil.upload(inputStream, relativePath);
            } else {
                // 本地存储暂不支持直接输入流上传
                log.error("本地存储不支持直接输入流上传");
                throw new RuntimeException("本地存储不支持直接输入流上传");
            }
        } catch (Exception e) {
            log.error("文件上传失败: {}", e.getMessage(), e);
            throw new RuntimeException("文件上传失败", e);
        }
    }

    /**
     * 获取文件流
     * 
     * @param bucketName 桶名
     * @param objectName 对象名
     * @param uploadType 上传类型
     * @return 文件输入流
     */
    public static InputStream getFile(String bucketName, String objectName, String uploadType) {
        try {
            if (CommonConstant.UPLOAD_TYPE_MINIO.equals(uploadType)) {
                return MinioUtil.getMinioFile(bucketName, objectName);
            } else if (CommonConstant.UPLOAD_TYPE_OSS.equals(uploadType)) {
                return OssBootUtil.getOssFile(bucketName, objectName);
            } else {
                // 本地存储暂不支持直接获取文件流
                log.error("本地存储不支持直接获取文件流");
                return null;
            }
        } catch (Exception e) {
            log.error("获取文件失败: {}", e.getMessage(), e);
            return null;
        }
    }

    /**
     * 删除文件
     * 
     * @param bucketName 桶名
     * @param objectName 对象名
     * @param uploadType 上传类型
     */
    public static void deleteFile(String bucketName, String objectName, String uploadType) {
        try {
            if (CommonConstant.UPLOAD_TYPE_MINIO.equals(uploadType)) {
                MinioUtil.removeObject(bucketName, objectName);
            } else if (CommonConstant.UPLOAD_TYPE_OSS.equals(uploadType)) {
                // 使用OSS的delete方法
                if (oConvertUtils.isEmpty(bucketName)) {
                    // 如果没有指定桶名，直接使用默认桶
                    OssBootUtil.delete(objectName);
                } else {
                    // 如果指定了桶名，使用deleteUrl方法
                    // 由于无法获取OssBootUtil的endPoint，这里简化处理
                    OssBootUtil.deleteUrl(objectName, bucketName);
                }
            } else {
                // 本地存储暂不支持直接删除文件
                log.error("本地存储不支持直接删除文件");
            }
        } catch (Exception e) {
            log.error("删除文件失败: {}", e.getMessage(), e);
        }
    }

    /**
     * 获取文件外链
     * 
     * @param bucketName 桶名
     * @param objectName 对象名
     * @param expires    过期时间（秒）
     * @param uploadType 上传类型
     * @return 文件URL
     */
    public static String getObjectUrl(String bucketName, String objectName, Integer expires, String uploadType) {
        try {
            if (CommonConstant.UPLOAD_TYPE_MINIO.equals(uploadType)) {
                return MinioUtil.getObjectUrl(bucketName, objectName, expires);
            } else if (CommonConstant.UPLOAD_TYPE_OSS.equals(uploadType)) {
                // 将秒转换为Date对象
                Date expireDate = new Date(System.currentTimeMillis() + expires * 1000L);
                return OssBootUtil.getObjectUrl(bucketName, objectName, expireDate);
            } else {
                // 本地存储返回相对路径
                return objectName;
            }
        } catch (Exception e) {
            log.error("获取文件URL失败: {}", e.getMessage(), e);
            return null;
        }
    }
}