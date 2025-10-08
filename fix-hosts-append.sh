#!/bin/sh
# 创建新的hosts文件，排除已有的localhost条目
cat /etc/hosts | grep -v 'localhost' > /tmp/new_hosts
# 添加我们的localhost映射
cat /tmp/temp_hosts.txt >> /tmp/new_hosts
# 查看新的hosts文件内容
cat /tmp/new_hosts
# 尝试覆盖hosts文件（可能需要特殊权限）
cp /tmp/new_hosts /etc/hosts
# 重启supervisor服务使更改生效
supervisorctl stop all
supervisorctl start all