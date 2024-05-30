CREATE SCHEMA minio.asahi WITH(LOCATION = 's3a://asahi_data/');
USE minio.asahi;

CREATE TABLE IF NOT EXISTS minio.asahi.answers_00101 (
  uuid varchar,
  user_id_code varchar,
  entried_at varchar,
  option_uuids array<varchar>,
  type_kbn varchar,
  item_uuid varchar,
  survey_uuid varchar
)
WITH (
  external_location = 's3://asahi_data/output/large/00101/type_kbn=00101',
  format = 'parquet',
  partitioned_by = ARRAY['item_uuid', 'survey_uuid']
);
CALL system.sync_partition_metadata('asahi', 'answers_00101', 'ADD');

CREATE TABLE IF NOT EXISTS minio.asahi.answers_00102 (
  uuid varchar,
  user_id_code varchar,
  entried_at varchar,
  option_uuids array<varchar>,
  type_kbn varchar,
  item_uuid varchar,
  survey_uuid varchar
)
WITH (
  external_location = 's3://asahi_data/output/large/00102/type_kbn=00102',
  format = 'parquet',
  partitioned_by = ARRAY['item_uuid', 'survey_uuid']
);
CALL system.sync_partition_metadata('asahi', 'answers_00102', 'ADD');

CREATE TABLE IF NOT EXISTS minio.asahi.answers_00104 (
  uuid varchar,
  user_id_code varchar,
  entried_at varchar,
  option_uuids array<varchar>,
  type_kbn varchar,
  item_uuid varchar,
  survey_uuid varchar
)
WITH (
  external_location = 's3://asahi_data/output/large/00104/type_kbn=00104',
  format = 'parquet',
  partitioned_by = ARRAY['item_uuid', 'survey_uuid']
);
CALL system.sync_partition_metadata('asahi', 'answers_00104', 'ADD');

CREATE TABLE IF NOT EXISTS minio.asahi.answers_00105 (
  uuid varchar,
  user_id_code varchar,
  entried_at varchar,
  option_uuids array<varchar>,
  type_kbn varchar,
  item_uuid varchar,
  survey_uuid varchar
)
WITH (
  external_location = 's3://asahi_data/output/large/00105/type_kbn=00105',
  format = 'parquet',
  partitioned_by = ARRAY['item_uuid', 'survey_uuid']
);
CALL system.sync_partition_metadata('asahi', 'answers_00105', 'ADD');