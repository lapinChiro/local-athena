#!/bin/sh 

log() {
    local glue_container_name="glue-minio-trino-glue-1"
    local trino_container_name="glue-minio-trino-trino-1"
    local hive_metastore_container_name="glue-minio-trino-hive-metastore-1"
    local minio_container_name="glue-minio-trino-minio-1"

    local subcommand=$1; [ $# -gt 0 ] && shift
    case $subcommand in
        "glue"           ) show_log $glue_container_name ;;
        "trino"          ) show_log $trino_container_name ;;
        "hive_metastore" ) show_log $hive_metastore_container_name ;;
        "minio"          ) show_log $minio_container_name ;;
        *                ) usage ;;
    esac
}

show_log() {
    docker container logs -f "$@"
}

usage() {
    echo 'Commands:' 1>&2
    echo ' log glue               glueコンテナのログを表示する' 1>&2
    echo ' log trino              trinoコンテナのログを表示する' 1>&2
    echo ' log hive_metastore     hive_metastoreコンテナのログを表示する' 1>&2
    echo ' log minio              minioコンテナのログを表示する' 1>&2
}

log "$@"