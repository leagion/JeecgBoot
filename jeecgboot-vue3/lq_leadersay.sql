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

 Date: 06/09/2025 23:08:05
*/


-- ----------------------------
-- Table structure for lq_leadersay
-- ----------------------------
DROP TABLE IF EXISTS "public"."lq_leadersay";
CREATE TABLE "public"."lq_leadersay" (
  "id" varchar(36) COLLATE "pg_catalog"."default" NOT NULL,
  "create_time" date,
  "update_by" varchar(50) COLLATE "pg_catalog"."default",
  "update_time" timestamp(6),
  "say_date" date NOT NULL,
  "leadername" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "leadersay" text COLLATE "pg_catalog"."default" NOT NULL,
  "doit" text COLLATE "pg_catalog"."default",
  "responsibleUnit" varchar(32) COLLATE "pg_catalog"."default",
  "validityPeriod" date,
  "remark" text COLLATE "pg_catalog"."default",
  "isfinished" char(1) COLLATE "pg_catalog"."default" DEFAULT 'N'::bpchar,
  "isshow" char(1) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'Y'::bpchar
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
-- Indexes structure for table lq_leadersay
-- ----------------------------
CREATE INDEX "idx_isfinished" ON "public"."lq_leadersay" USING btree (
  "isfinished" COLLATE "pg_catalog"."default" "pg_catalog"."bpchar_ops" ASC NULLS LAST
);
CREATE INDEX "idx_isshow" ON "public"."lq_leadersay" USING btree (
  "isshow" COLLATE "pg_catalog"."default" "pg_catalog"."bpchar_ops" ASC NULLS LAST
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
