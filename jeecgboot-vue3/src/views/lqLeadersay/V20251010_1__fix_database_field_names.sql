-- 数据库字段名修改脚本
-- 目的：将数据库中的字段从下划线命名改为驼峰命名，以匹配Java实体类和前端字段名

-- 连接到数据库：aiccg_pgdb
-- 执行此脚本以修复责任单位、完成时限、是否完成、是否显示四个字段无法保存的问题

-- 注意：执行前请备份数据库！

-- 修改责任单位字段
ALTER TABLE lq_leadersay
    RENAME COLUMN responsibleunit TO responsibleUnit;

-- 修改完成时限字段
ALTER TABLE lq_leadersay
    RENAME COLUMN validityperiod TO validityPeriod;

-- 修改是否完成字段
ALTER TABLE lq_leadersay
    RENAME COLUMN isfinished TO isfinished;

-- 修改是否显示字段
ALTER TABLE lq_leadersay
    RENAME COLUMN isshow TO isshow;

-- 如果有相关索引，也需要重新创建（如果原索引依赖这些字段）
-- 先删除旧索引
DROP INDEX IF EXISTS idx_lq_leadersay_responsible_unit;
DROP INDEX IF EXISTS idx_lq_leadersay_validity_period;
DROP INDEX IF EXISTS idx_lq_leadersay_is_finished;
DROP INDEX IF EXISTS idx_lq_leadersay_is_show;

-- 创建新索引
CREATE INDEX IF NOT EXISTS idx_lq_leadersay_responsibleunit ON lq_leadersay USING btree (responsibleUnit);
CREATE INDEX IF NOT EXISTS idx_lq_leadersay_validityperiod ON lq_leadersay USING btree (validityPeriod);
CREATE INDEX IF NOT EXISTS idx_lq_leadersay_isfinished ON lq_leadersay USING btree (isfinished);
CREATE INDEX IF NOT EXISTS idx_lq_leadersay_isshow ON lq_leadersay USING btree (isshow);

-- 验证修改结果
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'lq_leadersay' 
AND column_name IN ('responsibleUnit', 'validityPeriod', 'isfinished', 'isshow');

-- 执行成功后，请重启应用使更改生效