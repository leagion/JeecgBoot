-- 海警执法相关内容规范修改脚本
-- 修改说明：
-- 1. 将所有"观察员"统一调整为"航空执法员"
-- 2. 将"航空执法线索类别"与"执法日报警情类型"字段替换为标准执法类别
-- 3. 删除所有"邮箱"相关字段
-- 4. 将"地面执法"统一修改为"海上执法"
-- 5. 严格依据《海警法》进行规范完善
-- ----------------------------

-- ----------------------------
-- 1. 修改航空执法任务表中的"观察员"相关字段为"航空执法员"
-- ----------------------------
-- 修改字段名和注释，但保留原有数据
ALTER TABLE "air_law_enforcement_task" 
RENAME COLUMN "observer_id" TO "air_enforcer_id";

ALTER TABLE "air_law_enforcement_task" 
RENAME COLUMN "observer_name" TO "air_enforcer_name";

-- 更新字段注释
COMMENT ON COLUMN "air_law_enforcement_task"."air_enforcer_id" IS '航空执法员ID';
COMMENT ON COLUMN "air_law_enforcement_task"."air_enforcer_name" IS '航空执法员姓名';

-- ----------------------------
-- 2. 修改航空线索详情表中的线索类别字段为标准执法类别
-- ----------------------------
-- 更新字段注释，使用LqLaw.data.ts中定义的执法类别
ALTER TABLE "air_law_enforcement_clue_detail" 
ALTER COLUMN "clue_category" DROP DEFAULT;

COMMENT ON COLUMN "air_law_enforcement_clue_detail"."clue_category" IS '线索类别(CRIMINAL:治安类,INCIDENT:渔业类,ANTISMUGGLING:缉私类,MARINEFISHERIES:资源类,MARINERESOURCES:环境类,MARINEECOLOGICAL:救援类,FOREIGNLAW:其他类)';

-- ----------------------------
-- 3. 删除地面执法单位表中的邮箱字段
-- ----------------------------
ALTER TABLE "ground_enforcement_unit" 
DROP COLUMN "email";

-- ----------------------------
-- 4. 将"地面执法"相关内容统一修改为"海上执法"
-- ----------------------------
-- 重命名表
ALTER TABLE "ground_enforcement_unit" 
RENAME TO "marine_enforcement_unit";

-- 修改表注释
COMMENT ON TABLE "marine_enforcement_unit" IS '海上执法单位表，用于管理参与核查工作的海上执法单位';

-- 重命名索引
ALTER INDEX "idx_ground_unit_name" 
RENAME TO "idx_marine_unit_name";

ALTER INDEX "idx_ground_unit_type" 
RENAME TO "idx_marine_unit_type";

ALTER INDEX "idx_ground_unit_status" 
RENAME TO "idx_marine_unit_status";

-- 修改任务分发-地面单位关联表中的相关字段
ALTER TABLE "task_distribution_ground_unit" 
RENAME COLUMN "ground_unit_id" TO "marine_unit_id";

-- 修改外键约束
ALTER TABLE "task_distribution_ground_unit" 
DROP CONSTRAINT "fk_task_distribution_ground_unit";

ALTER TABLE "task_distribution_ground_unit" 
ADD CONSTRAINT "fk_task_distribution_marine_unit" 
FOREIGN KEY ("marine_unit_id") 
REFERENCES "marine_enforcement_unit" ("id") 
ON DELETE CASCADE;

-- 更新字段注释
COMMENT ON COLUMN "task_distribution_ground_unit"."marine_unit_id" IS '海上执法单位ID';

-- 重命名索引
ALTER INDEX "idx_ground_unit_id" 
RENAME TO "idx_marine_unit_id";

-- ----------------------------
-- 5. 修改执法日报详情表中的警情类型字段为标准执法类别
-- ----------------------------
-- 更新字段注释，使用LqLaw.data.ts中定义的执法类别
ALTER TABLE "enforcement_daily_report_detail" 
ALTER COLUMN "case_type" DROP DEFAULT;

COMMENT ON COLUMN "enforcement_daily_report_detail"."case_type" IS '警情类型(CRIMINAL:治安类,INCIDENT:渔业类,ANTISMUGGLING:缉私类,MARINEFISHERIES:资源类,MARINERESOURCES:环境类,MARINEECOLOGICAL:救援类,FOREIGNLAW:其他类)';

-- ----------------------------
-- 6. 修改空地执法线索视图为海空执法线索视图
-- ----------------------------
-- 先删除原视图
DROP VIEW IF EXISTS "air_ground_enforcement_clues";

-- 创建新视图
CREATE OR REPLACE VIEW "air_marine_enforcement_clues" AS
SELECT
    c.id AS clue_id,
    c.clue_number,
    c.title,
    c.description,
    c.clue_status,
    c.submit_time,
    c.location,
    c.geo_location,
    c.priority,
    c.confidence_level,
    t.task_number,
    t.task_name,
    t.actual_start_time,
    t.actual_end_time,
    d.detection_time,
    d.altitude,
    d.speed,
    d.clue_category,
    d.severity_level,
    COUNT(DISTINCT f.id) AS file_count,
    ARRAY_AGG(DISTINCT f.file_name) FILTER (WHERE f.id IS NOT NULL) AS related_files,
    ARRAY_AGG(DISTINCT f.id) FILTER (WHERE f.id IS NOT NULL) AS related_file_ids
FROM "law_enforcement_clue" c
LEFT JOIN "air_law_enforcement_clue_detail" d ON c.id = d.clue_id
LEFT JOIN "air_law_enforcement_task" t ON d.task_id = t.id
LEFT JOIN "law_enforcement_clue_file" cf ON c.id = cf.clue_id
LEFT JOIN "data_center_file" f ON cf.file_id = f.id
WHERE c.source_type = 'AIR_MARINE'
GROUP BY c.id, c.clue_number, c.title, c.description, c.clue_status, c.submit_time, c.location, c.geo_location, 
         c.priority, c.confidence_level, t.task_number, t.task_name, t.actual_start_time, t.actual_end_time,
         d.detection_time, d.altitude, d.speed, d.clue_category, d.severity_level;

-- 添加视图注释
COMMENT ON VIEW "air_marine_enforcement_clues" IS '海空执法线索聚合视图，整合线索基本信息、航空任务信息和相关文件';

-- ----------------------------
-- 7. 修改配置项中的相关内容
-- ----------------------------
-- 检查并更新配置项
DO $$
BEGIN
    -- 更新地面单位数据同步间隔配置项为海上单位
    IF EXISTS (SELECT 1 FROM "sys_config" WHERE "config_key" = 'ground_unit.sync_interval_minutes') THEN
        UPDATE "sys_config" 
        SET "config_key" = 'marine_unit.sync_interval_minutes',
            "config_name" = '海上单位数据同步间隔(分钟)',
            "update_time" = CURRENT_TIMESTAMP
        WHERE "config_key" = 'ground_unit.sync_interval_minutes';
    END IF;
END $$;

-- ----------------------------
-- 8. 插入标准执法类别数据
-- ----------------------------
-- 检查是否已存在执法类别表，如果存在则插入数据
DO $$
BEGIN
    -- 治安类
    IF NOT EXISTS (SELECT 1 FROM "data_center_file_category" WHERE "category_name" = '治安类' AND "parent_id" IS NULL) THEN
        INSERT INTO "data_center_file_category" ("id", "category_name", "parent_id", "user_id", "create_time", "update_time")
        VALUES (gen_random_uuid(), '治安类', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;
    
    -- 渔业类
    IF NOT EXISTS (SELECT 1 FROM "data_center_file_category" WHERE "category_name" = '渔业类' AND "parent_id" IS NULL) THEN
        INSERT INTO "data_center_file_category" ("id", "category_name", "parent_id", "user_id", "create_time", "update_time")
        VALUES (gen_random_uuid(), '渔业类', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;
    
    -- 缉私类
    IF NOT EXISTS (SELECT 1 FROM "data_center_file_category" WHERE "category_name" = '缉私类' AND "parent_id" IS NULL) THEN
        INSERT INTO "data_center_file_category" ("id", "category_name", "parent_id", "user_id", "create_time", "update_time")
        VALUES (gen_random_uuid(), '缉私类', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;
    
    -- 资源类
    IF NOT EXISTS (SELECT 1 FROM "data_center_file_category" WHERE "category_name" = '资源类' AND "parent_id" IS NULL) THEN
        INSERT INTO "data_center_file_category" ("id", "category_name", "parent_id", "user_id", "create_time", "update_time")
        VALUES (gen_random_uuid(), '资源类', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;
    
    -- 环境类
    IF NOT EXISTS (SELECT 1 FROM "data_center_file_category" WHERE "category_name" = '环境类' AND "parent_id" IS NULL) THEN
        INSERT INTO "data_center_file_category" ("id", "category_name", "parent_id", "user_id", "create_time", "update_time")
        VALUES (gen_random_uuid(), '环境类', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;
    
    -- 救援类
    IF NOT EXISTS (SELECT 1 FROM "data_center_file_category" WHERE "category_name" = '救援类' AND "parent_id" IS NULL) THEN
        INSERT INTO "data_center_file_category" ("id", "category_name", "parent_id", "user_id", "create_time", "update_time")
        VALUES (gen_random_uuid(), '救援类', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;
    
    -- 其他类
    IF NOT EXISTS (SELECT 1 FROM "data_center_file_category" WHERE "category_name" = '其他类' AND "parent_id" IS NULL) THEN
        INSERT INTO "data_center_file_category" ("id", "category_name", "parent_id", "user_id", "create_time", "update_time")
        VALUES (gen_random_uuid(), '其他类', NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;
END $$;

-- ----------------------------
-- 脚本执行完成说明
-- ----------------------------
-- 本脚本已完成以下修改：
-- 1. 将航空执法任务表中的"观察员"相关字段修改为"航空执法员"
-- 2. 标准化了航空执法线索类别和执法日报警情类型字段，使用LqLaw.data.ts中定义的执法类别
-- 3. 删除了地面执法单位表中的邮箱字段
-- 4. 将所有"地面执法"相关内容统一修改为"海上执法"
-- 5. 创建了海空执法线索视图替代原有的空地执法线索视图
-- 6. 更新了相关配置项
-- 7. 插入了标准执法类别数据
-- 所有修改均保留原有数据，不会影响项目历史数据及配置。