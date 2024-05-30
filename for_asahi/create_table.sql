CREATE SCHEMA minio.asahi WITH(LOCATION = 's3a://bucket001/');

CREATE TABLE IF NOT EXISTS minio.asahi.answers (
  uuid varchar,
  user_id_code varchar,
  entried_at varchar,
  option_uuids array<varchar>,
  type_kbn varchar,
  item_uuid varchar,
  survey_uuid varchar
)
WITH (
  external_location = 's3://bucket001/output/large/00101',
  format = 'parquet',
  partitioned_by = ARRAY['type_kbn', 'item_uuid', 'survey_uuid']
);

USE minio.asahi;
CALL system.sync_partition_metadata('asahi', 'answers', 'ADD');