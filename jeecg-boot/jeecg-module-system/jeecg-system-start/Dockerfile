FROM registry.cn-hangzhou.aliyuncs.com/dockerhub_mirror/java:17-anolis

MAINTAINER jeecgos@163.com

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#RUN mkdir -p /jeecg-boot/config/jeecg/

WORKDIR /jeecg-boot

EXPOSE 8080

#ADD ./src/main/resources/jeecg ./config/jeecg
ADD ./target/jeecg-system-start-3.8.2.jar ./

# 启动应用，绑定到所有网络接口
CMD java -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom -jar jeecg-system-start-3.8.2.jar --server.address=0.0.0.0