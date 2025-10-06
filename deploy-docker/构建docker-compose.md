
根据 ``e:\GitProjcetLQ\AIccgLQ\deploy-docker\all-docker-lq\docker-compose.yml`` 文件生成一个名为 ``docker-compose-lq.yml`` 的副本，放在根目录下，并进行一些修改。

修改要求包括：

1. 添加带中文环境的OnlyOffice，包含中文字体
2. 移除MySQL数据库，替换为PostgreSQL
3. PostgreSQL配置要求：
   - 密码：Admin@CCG2025
   - 创建新用户'lq'，密码hkzdlq@CCG2025
   - 在'lq'用户下创建aiccgDB并启用vector、postgis等扩展
   - 在'lq'用户下创建其他数据库：onlyofficeDB, redisDB, minioDBs
4. 网络配置为：networks: aiccg-networks
