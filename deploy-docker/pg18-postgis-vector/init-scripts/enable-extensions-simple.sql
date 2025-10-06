-- 检查当前存在的数据库
\c postgres;
SELECT datname FROM pg_database WHERE datistemplate = false;

-- 为onlyoffice数据库启用扩展（如果存在）
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'onlyoffice') THEN
    EXECUTE '\c onlyoffice';
    EXECUTE 'CREATE EXTENSION IF NOT EXISTS vector';
    EXECUTE 'CREATE EXTENSION IF NOT EXISTS postgis';
    EXECUTE 'CREATE EXTENSION IF NOT EXISTS postgis_topology';
    EXECUTE 'CREATE EXTENSION IF NOT EXISTS fuzzystrmatch';
    RAISE NOTICE 'Extensions enabled for database: onlyoffice';
    EXECUTE 'SELECT * FROM pg_extension';
  ELSE
    RAISE NOTICE 'Database onlyoffice does not exist';
  END IF;
END $$;