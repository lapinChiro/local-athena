create schema minio.bucket with(location = 's3a://trino-bucket/');

create table minio.bucket.people (
  family_id varchar,
  id varchar,
  first_name varchar,
  last_name varchar,
  age varchar
) with (
  format = 'csv',
  csv_separator = ',',
  csv_quote = '"',
  csv_escape = '"',
  skip_header_line_count = 1,
  external_location = 's3a://trino-bucket/input'
);