#!/bin/sh

restart() {

    local subcommand=$1
    [ $# -gt 0 ] && shift
    case $subcommand in
    "glue") restart_service glue ;;
    "trino") restart_service trino ;;
    "hive-metastore") restart_service hive-metastore ;;
    "minio") restart_service minio ;;
    *) usage ;;
    esac
}

restart_service() {
    docker compose restart "$@"
}

usage() {
    echo 'Commands:' 1>&2
    echo ' restart glue               glueコンテナを再起動する' 1>&2
    echo ' restart trino              trinoコンテナを再起動する' 1>&2
    echo ' restart hive-metastore     hive-metastoreコンテナを再起動する' 1>&2
    echo ' restart minio              minioコンテナを再起動する' 1>&2
}

restart "$@"

CREATE TABLE IF NOT EXISTS minio.default.tmp_00101_2 (
   participant_id varchar,
   option_uuid_array array < varchar >,
   entried_at timestamp,
   answer_uuid char(36)
 )
 WITH (
   format = 'parquet',
   external_location = 's3a://bucket001/sample/output/large/00101/type_kbn=00101/item_uuid=552703b5-a22f-47fe-9f2d-51b1f40cbe26/'
 );