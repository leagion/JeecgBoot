#!/bin/bash

umask 0022

start_process() {
  "$@" &
  CHILD=$!; wait "$CHILD"; CHILD="";
}

function clean_exit {
  [[ -z "$CHILD" ]] || kill -s SIGTERM "$CHILD" 2>/dev/null
  if [ ${ONLYOFFICE_DATA_CONTAINER:-false} == "false" ] && \
  [ ${ONLYOFFICE_DATA_CONTAINER_HOST:-localhost} == "localhost" ]; then
    /usr/bin/documentserver-prepare4shutdown.sh 2>/dev/null
  fi
  exit
}

trap clean_exit SIGTERM SIGQUIT SIGABRT SIGINT

shopt -s globstar

APP_DIR="/var/www/${COMPANY_NAME}/documentserver"
DATA_DIR="/var/www/${COMPANY_NAME}/Data"
PRIVATE_DATA_DIR="${DATA_DIR}/.private"
DS_RELEASE_DATE="${PRIVATE_DATA_DIR}/ds_release_date"
LOG_DIR="/var/log/${COMPANY_NAME}"
DS_LOG_DIR="${LOG_DIR}/documentserver"
LIB_DIR="/var/lib/${COMPANY_NAME}"
DS_LIB_DIR="${LIB_DIR}/documentserver"
CONF_DIR="/etc/${COMPANY_NAME}/documentserver"
SUPERVISOR_CONF_DIR="/etc/supervisor/conf.d"
IS_UPGRADE="${IS_UPGRADE:-false}"
PLUGINS_ENABLED=${PLUGINS_ENABLED:-true}

ONLYOFFICE_DATA_CONTAINER=${ONLYOFFICE_DATA_CONTAINER:-false}
ONLYOFFICE_DATA_CONTAINER_HOST=${ONLYOFFICE_DATA_CONTAINER_HOST:-localhost}
ONLYOFFICE_DATA_CONTAINER_PORT=80

RELEASE_DATE="$(stat -c="%y" ${APP_DIR}/server/DocService/docservice 2>/dev/null | sed -r 's/=([0-9]+)-([0-9]+)-([0-9]+) ([0-9:.+ ]+)/\1-\2-\3/')";
if [ -f ${DS_RELEASE_DATE} ]; then
  PREV_RELEASE_DATE=$(head -n 1 ${DS_RELEASE_DATE})
else
  PREV_RELEASE_DATE="0"
fi

if [ "${RELEASE_DATE}" != "${PREV_RELEASE_DATE}" ]; then
  if [ ${ONLYOFFICE_DATA_CONTAINER:-false} != "true" ]; then
    IS_UPGRADE="true";
  fi
fi

SSL_CERTIFICATES_DIR="/usr/share/ca-certificates/ds"; mkdir -p ${SSL_CERTIFICATES_DIR}
find "${DATA_DIR}/certs" -type f \( -iname '*.crt' -o -iname '*.pem' -o -iname '*.key' \) -exec cp -f {} "${SSL_CERTIFICATES_DIR}"/ \;
if find "${SSL_CERTIFICATES_DIR}" -maxdepth 1 -type f | read _; then
  find "${SSL_CERTIFICATES_DIR}" -type f \( -iname '*.crt' -o -iname '*.pem' \) -exec chmod 644 {} \;
  find "${SSL_CERTIFICATES_DIR}" -type f -iname '*.key' -exec chmod 400 {} \;
fi

if [[ -z $SSL_CERTIFICATE_PATH ]] && [[ -f ${SSL_CERTIFICATES_DIR}/${COMPANY_NAME}.crt ]]; then
  SSL_CERTIFICATE_PATH=${SSL_CERTIFICATES_DIR}/${COMPANY_NAME}.crt
else
  SSL_CERTIFICATE_PATH=${SSL_CERTIFICATE_PATH:-${SSL_CERTIFICATES_DIR}/tls.crt}
fi
if [[ -z $SSL_KEY_PATH ]] && [[ -f ${SSL_CERTIFICATES_DIR}/${COMPANY_NAME}.key ]]; then
  SSL_KEY_PATH=${SSL_CERTIFICATES_DIR}/${COMPANY_NAME}.key
else
  SSL_KEY_PATH=${SSL_KEY_PATH:-${SSL_CERTIFICATES_DIR}/tls.key}
fi

NODE_EXTRA_CA_CERTS=${NODE_EXTRA_CA_CERTS:-${SSL_CERTIFICATES_DIR}/extra-ca-certs.pem}
if [[ -f ${NODE_EXTRA_CA_CERTS} ]]; then
  NODE_EXTRA_ENVIRONMENT="${NODE_EXTRA_CA_CERTS}"
elif [[ -f ${SSL_CERTIFICATE_PATH} ]]; then
  SSL_CERTIFICATE_SUBJECT=$(openssl x509 -subject -noout -in "${SSL_CERTIFICATE_PATH}" 2>/dev/null | sed 's/subject=//')
  SSL_CERTIFICATE_ISSUER=$(openssl x509 -issuer -noout -in "${SSL_CERTIFICATE_PATH}" 2>/dev/null | sed 's/issuer=//')
  if [[ -n $SSL_CERTIFICATE_SUBJECT && $SSL_CERTIFICATE_SUBJECT == $SSL_CERTIFICATE_ISSUER ]]; then
    NODE_EXTRA_ENVIRONMENT="${SSL_CERTIFICATE_PATH}"
  fi
fi

if [[ -n $NODE_EXTRA_ENVIRONMENT ]]; then
  sed -i "s|^environment=.*$|&,NODE_EXTRA_CA_CERTS=${NODE_EXTRA_ENVIRONMENT}|" /etc/supervisor/conf.d/*.conf 2>/dev/null
fi

CA_CERTIFICATES_PATH=${CA_CERTIFICATES_PATH:-${SSL_CERTIFICATES_DIR}/ca-certificates.pem}
SSL_DHPARAM_PATH=${SSL_DHPARAM_PATH:-${SSL_CERTIFICATES_DIR}/dhparam.pem}
SSL_VERIFY_CLIENT=${SSL_VERIFY_CLIENT:-off}
USE_UNAUTHORIZED_STORAGE=${USE_UNAUTHORIZED_STORAGE:-false}
ONLYOFFICE_HTTPS_HSTS_ENABLED=${ONLYOFFICE_HTTPS_HSTS_ENABLED:-true}
ONLYOFFICE_HTTPS_HSTS_MAXAGE=${ONLYOFFICE_HTTPS_HSTS_MAXAGE:-31536000}
SYSCONF_TEMPLATES_DIR="/app/ds/setup/config"

NGINX_CONFD_PATH="/etc/nginx/conf.d";
NGINX_ONLYOFFICE_PATH="${CONF_DIR}/nginx"
NGINX_ONLYOFFICE_CONF="${NGINX_ONLYOFFICE_PATH}/ds.conf"
NGINX_ONLYOFFICE_EXAMPLE_PATH="${CONF_DIR}-example/nginx"
NGINX_ONLYOFFICE_EXAMPLE_CONF="${NGINX_ONLYOFFICE_EXAMPLE_PATH}/includes/ds-example.conf"

NGINX_CONFIG_PATH="/etc/nginx/nginx.conf"
NGINX_WORKER_PROCESSES=${NGINX_WORKER_PROCESSES:-1}
LIMIT=$(ulimit -n 2>/dev/null); [ -z "$LIMIT" ] && LIMIT=1024; [ $LIMIT -gt 1048576 ] && LIMIT=1048576
NGINX_WORKER_CONNECTIONS=${NGINX_WORKER_CONNECTIONS:-$LIMIT}
RABBIT_CONNECTIONS=${RABBIT_CONNECTIONS:-$LIMIT}

JWT_ENABLED=${JWT_ENABLED:-false}
if [ "${JWT_ENABLED}" == "true" ]; then
  JWT_ENABLED="true"
else
  JWT_ENABLED="false"
fi

[ -z $JWT_SECRET ] && JWT_MESSAGE='JWT is disabled (configured in Dockerfile)'
JWT_SECRET=${JWT_SECRET:-$(pwgen -s 32 2>/dev/null)}
JWT_HEADER=${JWT_HEADER:-Authorization}
JWT_IN_BODY=${JWT_IN_BODY:-false}

WOPI_ENABLED=${WOPI_ENABLED:-false}
ALLOW_META_IP_ADDRESS=${ALLOW_META_IP_ADDRESS:-true}
ALLOW_PRIVATE_IP_ADDRESS=${ALLOW_PRIVATE_IP_ADDRESS:-true}

GENERATE_FONTS=${GENERATE_FONTS:-true}

# 启用Redis（不再强制禁用）
# REDIS_ENABLED=false

ONLYOFFICE_DEFAULT_CONFIG=${CONF_DIR}/local.json
ONLYOFFICE_LOG4JS_CONFIG=${CONF_DIR}/log4js/production.json
ONLYOFFICE_EXAMPLE_CONFIG=${CONF_DIR}-example/local.json

JSON_BIN=${APP_DIR}/npm/json
JSON="${JSON_BIN} -f ${ONLYOFFICE_DEFAULT_CONFIG} 2>/dev/null"
JSON_LOG="${JSON_BIN} -f ${ONLYOFFICE_LOG4JS_CONFIG} 2>/dev/null"
JSON_EXAMPLE="${JSON_BIN} -f ${ONLYOFFICE_EXAMPLE_CONFIG} 2>/dev/null"

LOCAL_SERVICES=()

PG_ROOT=/var/lib/postgresql
PG_NAME=main
PGDATA=${PG_ROOT}/${PG_VERSION:-14}/${PG_NAME}
PG_NEW_CLUSTER=false
RABBITMQ_DATA=/var/lib/rabbitmq
REDIS_DATA=/var/lib/redis

if [ "${LETS_ENCRYPT_DOMAIN}" != "" -a "${LETS_ENCRYPT_MAIL}" != "" ]; then
  LETSENCRYPT_ROOT_DIR="/etc/letsencrypt/live"
  SSL_CERTIFICATE_PATH=${LETSENCRYPT_ROOT_DIR}/${LETS_ENCRYPT_DOMAIN}/fullchain.pem
  SSL_KEY_PATH=${LETSENCRYPT_ROOT_DIR}/${LETS_ENCRYPT_DOMAIN}/privkey.pem
fi

read_setting(){
  deprecated_var POSTGRESQL_SERVER_HOST DB_HOST
  deprecated_var POSTGRESQL_SERVER_PORT DB_PORT
  deprecated_var POSTGRESQL_SERVER_DB_NAME DB_NAME
  deprecated_var POSTGRESQL_SERVER_USER DB_USER
  deprecated_var POSTGRESQL_SERVER_PASS DB_PWD

  METRICS_ENABLED="${METRICS_ENABLED:-false}"
  METRICS_HOST="${METRICS_HOST:-localhost}"
  METRICS_PORT="${METRICS_PORT:-8125}"
  METRICS_PREFIX="${METRICS_PREFIX:-.ds}"

  # 强制DB_TYPE默认为postgres（关键修复）
  DB_HOST=${DB_HOST:-${POSTGRESQL_SERVER_HOST:-$(${JSON_BIN} -q -f ${ONLYOFFICE_DEFAULT_CONFIG} services.CoAuthoring.sql.dbHost 2>/dev/null)}}
  # 若配置中未找到DB_TYPE，强制设为postgres
  DB_TYPE=${DB_TYPE:-${POSTGRESQL_SERVER_TYPE:-$(${JSON_BIN} -q -f ${ONLYOFFICE_DEFAULT_CONFIG} services.CoAuthoring.sql.dbtype 2>/dev/null)}}
  if [ -z "$DB_TYPE" ]; then
    DB_TYPE="postgres"  # 兜底默认值
  fi

  # 数据库端口根据类型自动适配
  case $DB_TYPE in
    "postgres")
      DB_PORT=${DB_PORT:-"5432"}
      ;;
    "mariadb"|"mysql")
      DB_PORT=${DB_PORT:-"3306"}
      ;;
    "dameng")
      DB_PORT=${DB_PORT:-"5236"}
      ;;
    "mssql")
      DB_PORT=${DB_PORT:-"1433"}
      ;;
    "oracle")
      DB_PORT=${DB_PORT:-"1521"}
      ;;
    *)
      # 仅在非预期类型时报错（此时已通过默认值避免）
      echo "ERROR: unknown database type: $DB_TYPE"
      exit 1
      ;;
  esac

  # 其他数据库参数解析（保持不变）
  DB_NAME=${DB_NAME:-${POSTGRESQL_SERVER_DB_NAME:-$(${JSON_BIN} -q -f ${ONLYOFFICE_DEFAULT_CONFIG} services.CoAuthoring.sql.dbName 2>/dev/null)}}
  DB_USER=${DB_USER:-${POSTGRESQL_SERVER_USER:-$(${JSON_BIN} -q -f ${ONLYOFFICE_DEFAULT_CONFIG} services.CoAuthoring.sql.dbUser 2>/dev/null)}}
  DB_PWD=${DB_PWD:-${POSTGRESQL_SERVER_PASS:-$(${JSON_BIN} -q -f ${ONLYOFFICE_DEFAULT_CONFIG} services.CoAuthoring.sql.dbPass 2>/dev/null)}}

  # 解析AMQP相关变量（启用RabbitMQ）
  AMQP_URI=${AMQP_URI:-$(${JSON_BIN} -q -f ${ONLYOFFICE_DEFAULT_CONFIG} rabbitmq.url 2>/dev/null)}
  if [ -n "$AMQP_URI" ]; then
    parse_rabbitmq_url "$AMQP_URI"
  fi

  # 解析Redis相关变量（启用Redis）
  REDIS_SERVER_HOST=${REDIS_SERVER_HOST:-$(${JSON_BIN} -q -f ${ONLYOFFICE_DEFAULT_CONFIG} services.CoAuthoring.redis.host 2>/dev/null)}
  REDIS_SERVER_PORT=${REDIS_SERVER_PORT:-$(${JSON_BIN} -q -f ${ONLYOFFICE_DEFAULT_CONFIG} services.CoAuthoring.redis.port 2>/dev/null)}

  DS_LOG_LEVEL=${DS_LOG_LEVEL:-$(${JSON_BIN} -q -f ${ONLYOFFICE_LOG4JS_CONFIG} categories.default.level 2>/dev/null)}
}

deprecated_var() {
  if [[ -n ${!1} ]]; then
    echo "Variable $1 is deprecated. Use $2 instead."
  fi
}

# 解析RabbitMQ URL
parse_rabbitmq_url(){
  # 从AMQP_URI中提取主机和端口
  if [[ $1 =~ amqp://([^:]+):([^@]+)@([^:]+):([0-9]+) ]]; then
    AMQP_SERVER_HOST="${BASH_REMATCH[3]}"
    AMQP_SERVER_PORT="${BASH_REMATCH[4]}"
  fi
}

waiting_for_connection(){
  until nc -z -w 3 "$1" "$2"; do
    >&2 echo "Waiting for connection to the $1 host on port $2"
    sleep 1
  done
}

waiting_for_db_ready(){
  case $DB_TYPE in
    "oracle")
      ORACLE_SQL="sqlplus $DB_USER/$DB_PWD@//$DB_HOST:$DB_PORT/${DB_NAME} 2>/dev/null"
      DB_TEST="echo \"SELECT version FROM V\$INSTANCE;\" | $ORACLE_SQL | grep \"Connected\" | wc -l"
      ;;
    *)
      return
      ;;
  esac

  for (( i=1; i <= 10; i++ )); do
    RES=$(eval $DB_TEST)
    if [ "$RES" -ne "0" ]; then
      echo "Database is ready"
      break
    fi
    sleep 5
  done
}

waiting_for_db(){
  waiting_for_connection $DB_HOST $DB_PORT
  waiting_for_db_ready
}

# 等待RabbitMQ连接
waiting_for_amqp(){
  if [ -n "$AMQP_SERVER_HOST" ] && [ -n "$AMQP_SERVER_PORT" ]; then
    waiting_for_connection $AMQP_SERVER_HOST $AMQP_SERVER_PORT
  fi
}

# 等待Redis连接
waiting_for_redis(){
  if [ -n "$REDIS_SERVER_HOST" ] && [ -n "$REDIS_SERVER_PORT" ]; then
    waiting_for_connection $REDIS_SERVER_HOST $REDIS_SERVER_PORT
  fi
}

waiting_for_datacontainer(){
  waiting_for_connection ${ONLYOFFICE_DATA_CONTAINER_HOST} ${ONLYOFFICE_DATA_CONTAINER_PORT}
}

update_statsd_settings(){
  ${JSON} -e "if(this.statsd===undefined)this.statsd={};"
  ${JSON} -e "this.statsd.useMetrics = '${METRICS_ENABLED}'"
  ${JSON} -e "this.statsd.host = '${METRICS_HOST}'"
  ${JSON} -e "this.statsd.port = '${METRICS_PORT}'"
  ${JSON} -e "this.statsd.prefix = '${METRICS_PREFIX}'"
  sed -i -E "s/(autostart|autorestart)=.*$/\1=${METRICS_ENABLED}/g" ${SUPERVISOR_CONF_DIR}/ds-metrics.conf 2>/dev/null
}

update_db_settings(){
  ${JSON} -e "this.services.CoAuthoring.sql.dbtype = '${DB_TYPE}'"
  ${JSON} -e "this.services.CoAuthoring.sql.dbHost = '${DB_HOST}'"
  ${JSON} -e "this.services.CoAuthoring.sql.dbPort = '${DB_PORT}'"
  ${JSON} -e "this.services.CoAuthoring.sql.dbName = '${DB_NAME}'"
  ${JSON} -e "this.services.CoAuthoring.sql.dbUser = '${DB_USER}'"
  ${JSON} -e "this.services.CoAuthoring.sql.dbPass = '${DB_PWD}'"
}

# 更新RabbitMQ配置
update_rabbitmq_setting(){
  if [ -n "$AMQP_URI" ]; then
    ${JSON} -e "this.rabbitmq.url = '${AMQP_URI}'"
    ${JSON} -e "this.rabbitmq.connection.enabled = true"
  fi
}

# 更新Redis配置
update_redis_settings(){
  if [ -n "$REDIS_SERVER_HOST" ]; then
    ${JSON} -e "this.services.CoAuthoring.redis.host = '${REDIS_SERVER_HOST}'"
    ${JSON} -e "this.services.CoAuthoring.redis.port = ${REDIS_SERVER_PORT}"
    ${JSON} -e "this.services.CoAuthoring.redis.enabled = true"
  fi
}

update_ds_settings(){
  # 配置token（不涉及AMQP）
  ${JSON} -e "this.services.CoAuthoring.token.enable.browser = ${JWT_ENABLED}"
  ${JSON} -e "this.services.CoAuthoring.token.enable.request.inbox = ${JWT_ENABLED}"
  ${JSON} -e "this.services.CoAuthoring.token.enable.request.outbox = ${JWT_ENABLED}"

  ${JSON} -e "this.services.CoAuthoring.secret.inbox.string = '${JWT_SECRET}'"
  ${JSON} -e "this.services.CoAuthoring.secret.outbox.string = '${JWT_SECRET}'"
  ${JSON} -e "this.services.CoAuthoring.secret.session.string = '${JWT_SECRET}'"

  ${JSON} -e "this.services.CoAuthoring.token.inbox.header = '${JWT_HEADER}'"
  ${JSON} -e "this.services.CoAuthoring.token.outbox.header = '${JWT_HEADER}'"

  ${JSON} -e "this.services.CoAuthoring.token.inbox.inBody = ${JWT_IN_BODY}"
  ${JSON} -e "this.services.CoAuthoring.token.outbox.inBody = ${JWT_IN_BODY}"

  if [ -f "${ONLYOFFICE_EXAMPLE_CONFIG}" ]; then
    ${JSON_EXAMPLE} -e "this.server.token.enable = ${JWT_ENABLED}"
    ${JSON_EXAMPLE} -e "this.server.token.secret = '${JWT_SECRET}'"
    ${JSON_EXAMPLE} -e "this.server.token.authorizationHeader = '${JWT_HEADER}'"
  fi
 
  if [ "${USE_UNAUTHORIZED_STORAGE}" == "true" ]; then
    ${JSON} -e "if(this.services.CoAuthoring.requestDefaults===undefined)this.services.CoAuthoring.requestDefaults={}"
    ${JSON} -e "if(this.services.CoAuthoring.requestDefaults.rejectUnauthorized===undefined)this.services.CoAuthoring.requestDefaults.rejectUnauthorized=false"
  fi

  # 生成WOPI密钥（不涉及AMQP）
  WOPI_PRIVATE_KEY="${DATA_DIR}/wopi_private.key"
  WOPI_PUBLIC_KEY="${DATA_DIR}/wopi_public.key"

  [ ! -f "${WOPI_PRIVATE_KEY}" ] && echo -n "Generating WOPI private key..." && openssl genpkey -algorithm RSA -outform PEM -out "${WOPI_PRIVATE_KEY}" >/dev/null 2>&1 && echo "Done"
  [ ! -f "${WOPI_PUBLIC_KEY}" ] && echo -n "Generating WOPI public key..." && openssl rsa -RSAPublicKey_out -in "${WOPI_PRIVATE_KEY}" -outform "MS PUBLICKEYBLOB" -out "${WOPI_PUBLIC_KEY}" >/dev/null 2>&1  && echo "Done"
  WOPI_MODULUS=$(openssl rsa -pubin -inform "MS PUBLICKEYBLOB" -modulus -noout -in "${WOPI_PUBLIC_KEY}" 2>/dev/null | sed 's/Modulus=//' | xxd -r -p | openssl base64 -A)
  WOPI_EXPONENT=$(openssl rsa -pubin -inform "MS PUBLICKEYBLOB" -text -noout -in "${WOPI_PUBLIC_KEY}" 2>/dev/null | grep -oP '(?<=Exponent: )\d+')
  
  ${JSON} -e "if(this.wopi===undefined)this.wopi={};"
  ${JSON} -e "this.wopi.enable = ${WOPI_ENABLED}"
  ${JSON} -e "this.wopi.privateKey = '$(awk '{printf "%s\\n", $0}' ${WOPI_PRIVATE_KEY})'"
  ${JSON} -e "this.wopi.privateKeyOld = '$(awk '{printf "%s\\n", $0}' ${WOPI_PRIVATE_KEY})'"
  ${JSON} -e "this.wopi.publicKey = '$(openssl base64 -in ${WOPI_PUBLIC_KEY} -A)'"
  ${JSON} -e "this.wopi.publicKeyOld = '$(openssl base64 -in ${WOPI_PUBLIC_KEY} -A)'"
  ${JSON} -e "this.wopi.modulus = '${WOPI_MODULUS}'"
  ${JSON} -e "this.wopi.modulusOld = '${WOPI_MODULUS}'"
  ${JSON} -e "this.wopi.exponent = ${WOPI_EXPONENT}"
  ${JSON} -e "this.wopi.exponentOld = ${WOPI_EXPONENT}"

  # 配置IP过滤
  if [ "${ALLOW_META_IP_ADDRESS}" = "true" ] || [ "${ALLOW_PRIVATE_IP_ADDRESS}" = "true" ]; then
    ${JSON} -e "if(this.services.CoAuthoring['request-filtering-agent']===undefined)this.services.CoAuthoring['request-filtering-agent']={}"
    [ "${ALLOW_META_IP_ADDRESS}" = "true" ] && ${JSON} -e "this.services.CoAuthoring['request-filtering-agent'].allowMetaIPAddress = true"
    [ "${ALLOW_PRIVATE_IP_ADDRESS}" = "true" ] && ${JSON} -e "this.services.CoAuthoring['request-filtering-agent'].allowPrivateIPAddress = true"
  fi
}

create_postgresql_cluster(){
  local pg_conf_dir=/etc/postgresql/${PG_VERSION:-14}/${PG_NAME}
  local postgresql_conf=$pg_conf_dir/postgresql.conf
  local hba_conf=$pg_conf_dir/pg_hba.conf

  mv $postgresql_conf $postgresql_conf.backup 2>/dev/null
  mv $hba_conf $hba_conf.backup 2>/dev/null

  pg_createcluster ${PG_VERSION:-14} ${PG_NAME} 2>/dev/null
}

create_postgresql_db(){
  sudo -u postgres psql -c "CREATE USER $DB_USER WITH password '"$DB_PWD"';" 2>/dev/null
  sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null
}

create_mssql_db(){
  MSSQL="/opt/mssql-tools18/bin/sqlcmd -S $DB_HOST,$DB_PORT 2>/dev/null"
  $MSSQL -U $DB_USER -P "$DB_PWD" -C -Q "IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$DB_NAME') BEGIN CREATE DATABASE $DB_NAME; END"
}

create_db_tbl() {
  case $DB_TYPE in
    "postgres")
      create_postgresql_tbl
    ;;
    "mariadb"|"mysql")
      create_mysql_tbl
    ;;
    "mssql")
      create_mssql_tbl
    ;;
    "oracle")
      create_oracle_tbl
    ;;
  esac
}

upgrade_db_tbl() {
  case $DB_TYPE in
    "postgres")
      upgrade_postgresql_tbl
    ;;
    "mariadb"|"mysql")
      upgrade_mysql_tbl
    ;;
    "mssql")
      upgrade_mssql_tbl
    ;;
    "oracle")
      upgrade_oracle_tbl
    ;;
  esac
}

upgrade_postgresql_tbl() {
  if [ -n "$DB_PWD" ]; then
    export PGPASSWORD=$DB_PWD
  fi
  PSQL="psql -q -h$DB_HOST -p$DB_PORT -d$DB_NAME -U$DB_USER -w 2>/dev/null"
  $PSQL -f "$APP_DIR/server/schema/postgresql/removetbl.sql" 2>/dev/null
  $PSQL -f "$APP_DIR/server/schema/postgresql/createdb.sql" 2>/dev/null
}

upgrade_mysql_tbl() {
  CONNECTION_PARAMS="-h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD -w 2>/dev/null"
  MYSQL="mysql -q $CONNECTION_PARAMS"
  $MYSQL $DB_NAME < "$APP_DIR/server/schema/mysql/removetbl.sql" >/dev/null 2>&1
  $MYSQL $DB_NAME < "$APP_DIR/server/schema/mysql/createdb.sql" >/dev/null 2>&1
}

upgrade_mssql_tbl() {
  CONN_PARAMS="-d $DB_NAME -U $DB_USER -P "$DB_PWD" -C 2>/dev/null"
  MSSQL="/opt/mssql-tools18/bin/sqlcmd -S $DB_HOST,$DB_PORT $CONN_PARAMS"
  $MSSQL < "$APP_DIR/server/schema/mssql/removetbl.sql" >/dev/null 2>&1
  $MSSQL < "$APP_DIR/server/schema/mssql/createdb.sql" >/dev/null 2>&1
}

upgrade_oracle_tbl() {
  ORACLE_SQL="sqlplus $DB_USER/$DB_PWD@//$DB_HOST:$DB_PORT/${DB_NAME} 2>/dev/null"
  $ORACLE_SQL @$APP_DIR/server/schema/oracle/removetbl.sql >/dev/null 2>&1
  $ORACLE_SQL @$APP_DIR/server/schema/oracle/createdb.sql >/dev/null 2>&1
}

create_postgresql_tbl() {
  if [ -n "$DB_PWD" ]; then
    export PGPASSWORD=$DB_PWD
  fi
  PSQL="psql -q -h$DB_HOST -p$DB_PORT -d$DB_NAME -U$DB_USER -w 2>/dev/null"
  $PSQL -f "$APP_DIR/server/schema/postgresql/createdb.sql" 2>/dev/null
}

create_mysql_tbl() {
  CONNECTION_PARAMS="-h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PWD -w 2>/dev/null"
  MYSQL="mysql -q $CONNECTION_PARAMS"
  $MYSQL -e "CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;" >/dev/null 2>&1
  $MYSQL $DB_NAME < "$APP_DIR/server/schema/mysql/createdb.sql" >/dev/null 2>&1
}

create_mssql_tbl() {  
  create_mssql_db
  CONN_PARAMS="-d $DB_NAME -U $DB_USER -P "$DB_PWD" -C 2>/dev/null"
  MSSQL="/opt/mssql-tools18/bin/sqlcmd -S $DB_HOST,$DB_PORT $CONN_PARAMS"
  $MSSQL < "$APP_DIR/server/schema/mssql/createdb.sql" >/dev/null 2>&1
}

create_oracle_tbl() {
  ORACLE_SQL="sqlplus $DB_USER/$DB_PWD@//$DB_HOST:$DB_PORT/${DB_NAME} 2>/dev/null"
  $ORACLE_SQL @$APP_DIR/server/schema/oracle/createdb.sql >/dev/null 2>&1
}

update_welcome_page() {
  WELCOME_PAGE="${APP_DIR}-example/welcome/docker.html"
  if [[ -e $WELCOME_PAGE ]]; then
    DOCKER_CONTAINER_ID=$(basename $(cat /proc/1/cpuset 2>/dev/null))
    (( ${#DOCKER_CONTAINER_ID} < 12 )) && DOCKER_CONTAINER_ID=$(hostname 2>/dev/null)
    if (( ${#DOCKER_CONTAINER_ID} >= 12 )); then
      if [[ -x $(command -v docker) ]]; then
        DOCKER_CONTAINER_NAME=$(docker inspect --format="{{.Name}}" $DOCKER_CONTAINER_ID 2>/dev/null)
        sed 's/$(sudo docker ps -q)/'"${DOCKER_CONTAINER_NAME#/}"'/' -i $WELCOME_PAGE 2>/dev/null
        JWT_MESSAGE=$(echo $JWT_MESSAGE | sed 's/$(sudo docker ps -q)/'"${DOCKER_CONTAINER_NAME#/}"'/')
      else
        sed 's/$(sudo docker ps -q)/'"${DOCKER_CONTAINER_ID::12}"'/' -i $WELCOME_PAGE 2>/dev/null
        JWT_MESSAGE=$(echo $JWT_MESSAGE | sed 's/$(sudo docker ps -q)/'"${DOCKER_CONTAINER_ID::12}"'/')
      fi
    fi
  fi
}

update_nginx_settings(){
  sed 's/^worker_processes.*/'"worker_processes ${NGINX_WORKER_PROCESSES};"'/' -i ${NGINX_CONFIG_PATH} 2>/dev/null
  sed 's/worker_connections.*/'"worker_connections ${NGINX_WORKER_CONNECTIONS};"'/' -i ${NGINX_CONFIG_PATH} 2>/dev/null
  sed 's/access_log.*/'"access_log off;"'/' -i ${NGINX_CONFIG_PATH} 2>/dev/null

  if [ -f "${SSL_CERTIFICATE_PATH}" -a -f "${SSL_KEY_PATH}" ]; then
    cp -f ${NGINX_ONLYOFFICE_PATH}/ds-ssl.conf.tmpl ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
    sed 's,{{SSL_CERTIFICATE_PATH}},'"${SSL_CERTIFICATE_PATH}"',' -i ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
    sed 's,{{SSL_KEY_PATH}},'"${SSL_KEY_PATH}"',' -i ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
    sed 's,\(443 ssl\),\1 http2,' -i ${NGINX_ONLYOFFICE_CONF} 2>/dev/null

    if [ -r "${SSL_DHPARAM_PATH}" ]; then
      sed 's,\(\#* *\)\?\(ssl_dhparam \).*\(;\)$,'"\2${SSL_DHPARAM_PATH}\3"',' -i ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
    else
      sed '/ssl_dhparam/d' -i ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
    fi

    sed 's,\(ssl_verify_client \).*\(;\)$,'"\1${SSL_VERIFY_CLIENT}\2"',' -i ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
    if [ -f "${CA_CERTIFICATES_PATH}" ]; then
      sed '/ssl_verify_client/a '"ssl_client_certificate ${CA_CERTIFICATES_PATH}"';' -i ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
    fi

    if [ "${ONLYOFFICE_HTTPS_HSTS_ENABLED}" == "true" ]; then
      sed 's,\(max-age=\).*\(;\)$,'"\1${ONLYOFFICE_HTTPS_HSTS_MAXAGE}\2"',' -i ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
    else
      sed '/max-age=/d' -i ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
    fi
  else
    ln -sf ${NGINX_ONLYOFFICE_PATH}/ds.conf.tmpl ${NGINX_ONLYOFFICE_CONF} 2>/dev/null
  fi

  if [ ! -f /proc/net/if_inet6 ]; then
    sed '/listen\s\+\[::[0-9]*\].\+/d' -i $NGINX_ONLYOFFICE_CONF 2>/dev/null
  fi

  if [ -f "${NGINX_ONLYOFFICE_EXAMPLE_CONF}" ]; then
    sed 's/linux/docker/' -i ${NGINX_ONLYOFFICE_EXAMPLE_CONF} 2>/dev/null
  fi

  start_process documentserver-update-securelink.sh -s ${SECURE_LINK_SECRET:-$(pwgen -s 20 2>/dev/null)} -r false
}

update_log_settings(){
   ${JSON_LOG} -e "this.categories.default.level = '${DS_LOG_LEVEL}'" 2>/dev/null
}

update_logrotate_settings(){
  sed 's|\(^su\b\).*|\1 root root|' -i /etc/logrotate.conf 2>/dev/null
}

update_release_date(){
  mkdir -p ${PRIVATE_DATA_DIR} 2>/dev/null
  echo ${RELEASE_DATE} > ${DS_RELEASE_DATE} 2>/dev/null
}

# 创建基础目录
for i in converter docservice metrics; do
  mkdir -p "${DS_LOG_DIR}/$i" 2>/dev/null
done
mkdir -p ${DS_LOG_DIR}-example 2>/dev/null

# 创建应用目录
for i in ${DS_LIB_DIR}/App_Data/cache/files ${DS_LIB_DIR}/App_Data/docbuilder ${DS_LIB_DIR}-example/files; do
  mkdir -p "$i" 2>/dev/null
done

# 设置目录权限
chown ds:ds "${DATA_DIR}" 2>/dev/null
for i in ${DS_LOG_DIR} ${DS_LOG_DIR}-example ${LIB_DIR}; do
  chown -R ds:ds "$i" 2>/dev/null
  chmod -R 755 "$i" 2>/dev/null
done

# 修复runtime.json权限
AI_CONFIG_FILE="${DATA_DIR}/runtime.json"
[ -f "${AI_CONFIG_FILE}" ] && { chown ds:ds "${AI_CONFIG_FILE}" && chmod 644 "${AI_CONFIG_FILE}"; } 2>/dev/null

if [ ${ONLYOFFICE_DATA_CONTAINER_HOST:-localhost} = "localhost" ]; then
  read_setting

  if [ $METRICS_ENABLED = "true" ]; then
    update_statsd_settings
  fi

  update_welcome_page
  update_log_settings
  update_ds_settings
  update_rabbitmq_setting
  update_redis_settings

  # 数据库配置（外部PostgreSQL）
  if [ $DB_HOST != "localhost" ] && [ -n "${DB_HOST}" ]; then
    update_db_settings
    waiting_for_db
    create_db_tbl
  else
    chown -R postgres:postgres ${PG_ROOT} 2>/dev/null
    chmod -R 700 ${PG_ROOT} 2>/dev/null
    if [ ! -d ${PGDATA} ]; then
      create_postgresql_cluster
      PG_NEW_CLUSTER=true
    fi
    LOCAL_SERVICES+=("postgresql")
  fi

  # 等待RabbitMQ和Redis连接
  waiting_for_amqp
  waiting_for_redis

else
  waiting_for_datacontainer
  read_setting
  update_welcome_page
fi

find /etc/${COMPANY_NAME} ! -path '*logrotate*' -exec chown ds:ds {} \; 2>/dev/null

# 启动本地服务（仅PostgreSQL，无RabbitMQ/Redis）
for i in ${LOCAL_SERVICES[@]}; do
  service $i start 2>/dev/null
done

if [ ${PG_NEW_CLUSTER} = "true" ]; then
  create_postgresql_db
  create_postgresql_tbl
fi

if [ ${ONLYOFFICE_DATA_CONTAINER:-false} != "true" ]; then
  waiting_for_db
  waiting_for_amqp
  waiting_for_redis

  if [ "${IS_UPGRADE:-false}" = "true" ]; then
    upgrade_db_tbl
    update_release_date
  fi

  update_nginx_settings
  service supervisor start 2>/dev/null
  update_logrotate_settings
  service cron start 2>/dev/null
fi

# 清理缓存
start_process documentserver-flush-cache.sh -r false 2>/dev/null

# 启动nginx
service nginx start 2>/dev/null

# Let's Encrypt配置（按需启用）
if [ "${LETS_ENCRYPT_DOMAIN}" != "" -a "${LETS_ENCRYPT_MAIL}" != "" ]; then
  if [ ! -f "${SSL_CERTIFICATE_PATH}" -a ! -f "${SSL_KEY_PATH}" ]; then
    start_process documentserver-letsencrypt.sh ${LETS_ENCRYPT_MAIL} ${LETS_ENCRYPT_DOMAIN} 2>/dev/null
  fi
fi

# 生成字体缓存
if [ "${GENERATE_FONTS}" == "true" ]; then
  start_process documentserver-generate-allfonts.sh ${ONLYOFFICE_DATA_CONTAINER:-false} 2>/dev/null
  echo "Generating AllFonts.js, please wait...Done"
fi

# 安装插件
if [ "${PLUGINS_ENABLED}" = "true" ]; then
  echo -n "Installing plugins, please wait..."
  start_process documentserver-pluginsmanager.sh -r false --update=\"${APP_DIR}/sdkjs-plugins/plugin-list-default.json\" >/dev/null 2>&1
  echo "Done"
fi

start_process documentserver-static-gzip.sh ${ONLYOFFICE_DATA_CONTAINER:-false} 2>/dev/null

echo "${JWT_MESSAGE}" 

# 跟踪日志
start_process find "$DS_LOG_DIR" "$DS_LOG_DIR-example" -type f -name "*.log" | xargs tail -f 2>/dev/null