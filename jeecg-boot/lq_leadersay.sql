/*
 Navicat Premium Dump SQL

 Source Server         : aiccg_db
 Source Server Type    : PostgreSQL
 Source Server Version : 170005 (170005)
 Source Host           : localhost:5432
 Source Catalog        : aiccg_pgdb
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 170005 (170005)
 File Encoding         : 65001

 Date: 06/09/2025 23:34:49
*/


-- ----------------------------
-- Table structure for lq_leadersay
-- ----------------------------
DROP TABLE IF EXISTS "public"."lq_leadersay";
CREATE TABLE "public"."lq_leadersay" (
  "id" varchar(36) COLLATE "pg_catalog"."default" NOT NULL,
  "create_time" date,
  "update_by" varchar(50) COLLATE "pg_catalog"."default",
  "update_time" date,
  "say_date" date NOT NULL,
  "leadername" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "leadersay" text COLLATE "pg_catalog"."default" NOT NULL,
  "doit" text COLLATE "pg_catalog"."default",
  "responsibleUnit" varchar(32) COLLATE "pg_catalog"."default",
  "validityPeriod" date,
  "remark" text COLLATE "pg_catalog"."default",
  "isfinished" varchar(1) COLLATE "pg_catalog"."default" NOT NULL,
  "isshow" varchar(1) COLLATE "pg_catalog"."default" NOT NULL
)
;
COMMENT ON COLUMN "public"."lq_leadersay"."create_time" IS '创建日期';
COMMENT ON COLUMN "public"."lq_leadersay"."update_by" IS '更新人';
COMMENT ON COLUMN "public"."lq_leadersay"."update_time" IS '更新日期';
COMMENT ON COLUMN "public"."lq_leadersay"."say_date" IS '日期';
COMMENT ON COLUMN "public"."lq_leadersay"."leadername" IS '首长姓名';
COMMENT ON COLUMN "public"."lq_leadersay"."leadersay" IS '首长指示';
COMMENT ON COLUMN "public"."lq_leadersay"."doit" IS '落实情况';
COMMENT ON COLUMN "public"."lq_leadersay"."responsibleUnit" IS '责任单位';
COMMENT ON COLUMN "public"."lq_leadersay"."validityPeriod" IS '完成时限';
COMMENT ON COLUMN "public"."lq_leadersay"."remark" IS '备注';
COMMENT ON COLUMN "public"."lq_leadersay"."isfinished" IS '是否完成';
COMMENT ON COLUMN "public"."lq_leadersay"."isshow" IS '是否显示';

-- ----------------------------
-- Records of lq_leadersay
-- ----------------------------
INSERT INTO "public"."lq_leadersay" VALUES ('1964008306093113345', '2025-09-06', NULL, NULL, '2025-09-06', '丁丁', 'dfa daf ads fads', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964016363430789121', '2025-09-06', NULL, NULL, '2025-09-04', '李强', '分add发腮', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964016459568431105', '2025-09-06', NULL, NULL, '2025-09-25', '航海1', '扥啊阿赛', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964016496419586049', '2025-09-06', NULL, NULL, '2025-09-10', '丁丁', '分啊森达sad', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964016608726269954', '2025-09-06', NULL, NULL, '2025-09-10', '李强', '发动阿帆阿赛', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964016760581046273', '2025-09-06', NULL, NULL, '2025-08-01', '李强', '扥啊塞缝', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964147237459640321', '2025-09-06', NULL, NULL, '2025-09-30', '李强', 'qweqw ewq', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964150926920433665', '2025-09-06', NULL, NULL, '2025-09-27', '李强', 'cvzc', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964152916828274689', '2025-09-06', NULL, NULL, '2025-10-02', '李强', 'vzxc v', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964152987254833153', '2025-09-06', NULL, NULL, '2025-07-03', '李强', 'f cv z', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964243903709757442', '2025-09-06', NULL, NULL, '2025-11-08', '丁丁', 'fa fa ds', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964292336478896129', '2025-09-06', NULL, NULL, '2025-09-06', '李强', '修改内容：

- 在 LeaderSayDisplay.vue 文件中更新了 formatDate 函数
- 将 Intl.DateTimeFormat 配置中的 month 属性从 ''2-digit'' 改为 ''long''，使月份显示为中文全称
- 将 day 属性从 ''2-digit'' 改为 ''numeric''，保持日期数字显示的一致性
现在滚动播放内容中的日期将以更符合中文阅读习惯的格式展示，提升用户体验。', NULL, NULL, NULL, NULL, 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964306863064924162', '2025-09-06', 'admin', '2025-09-06', '2025-09-06', '李强', 'f asd fascv啊东方 扥啊', '落实了', NULL, NULL, '分阿赛11', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964014584072814594', '2025-09-06', 'admin', '2025-09-06', '2025-09-07', '丁丁', 'f ad f', '大森啊', NULL, NULL, '1发东方', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964014646408560641', '2025-09-06', 'admin', '2025-09-06', '2025-09-19', '李强', '法扥阿斗', '懂阿凡达', NULL, NULL, '扥啊', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964318620500148226', '2025-09-06', 'admin', '2025-09-06', '2025-09-06', '李强', '法森啊', '扥1133', NULL, NULL, '法1133', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964327818948558849', '2025-09-06', 'admin', '2025-09-06', '2025-09-06', '李强', '的阿斗', '的法', NULL, NULL, '的法', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964336031706169345', '2025-09-06', NULL, NULL, '2025-09-06', '李强', 'df', 'd a', NULL, NULL, 'fa', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964014688762642434', '2025-09-06', 'admin', '2025-09-06', '2025-09-11', '李强', '法扥啊', 'dfa', NULL, NULL, 'daf a', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964340192300548097', '2025-09-06', NULL, NULL, '2025-09-06', '李强', 'df a', 'df a', NULL, NULL, 'df a', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964014751719145473', '2025-09-06', 'admin', '2025-09-06', '2025-09-03', '夏夏', '法撒旦发动阿斗放到', 'dsf', NULL, NULL, 'daf a', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964341906353209345', '2025-09-06', NULL, NULL, '2025-09-06', '李强', 'daf', 'daf', NULL, NULL, 'daf a', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964015737376391169', '2025-09-06', 'admin', '2025-09-06', '2025-09-04', '李强', '分阿斗1', '111', NULL, NULL, '111', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964015830150201345', '2025-09-06', 'admin', '2025-09-06', '2025-09-04', '李强', '扥啊11', '11', NULL, NULL, '111', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964015934466736129', '2025-09-06', 'admin', '2025-09-06', '2025-09-02', '李强', '扥阿斗发动法找下最', '送', NULL, NULL, '送', 'N', 'Y');
INSERT INTO "public"."lq_leadersay" VALUES ('1964015971695378434', '2025-09-06', 'admin', '2025-09-06', '2025-09-13', '丁丁', '洗澡轴线在', 'ss', NULL, NULL, 's', 'N', 'Y');

-- ----------------------------
-- Indexes structure for table lq_leadersay
-- ----------------------------
CREATE INDEX "idx_isfinished" ON "public"."lq_leadersay" USING btree (
  "isfinished" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_isshow" ON "public"."lq_leadersay" USING btree (
  "isshow" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_responsibleunit" ON "public"."lq_leadersay" USING btree (
  "responsibleUnit" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_validityperiod" ON "public"."lq_leadersay" USING btree (
  "validityPeriod" "pg_catalog"."date_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table lq_leadersay
-- ----------------------------
ALTER TABLE "public"."lq_leadersay" ADD CONSTRAINT "lq_leadersay_pkey" PRIMARY KEY ("id");
