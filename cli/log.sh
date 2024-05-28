#!/bin/sh 

log() {

    local subcommand=$1; [ $# -gt 0 ] && shift
    case $subcommand in
        "glue"           ) show_log glue ;;
        "trino"          ) show_log trino ;;
        "hive_metastore" ) show_log hive-metastore ;;
        "minio"          ) show_log minio ;;
        *                ) usage ;;
    esac
}

show_log() {
    docker compose logs -f "$@"
}

usage() {
    echo 'Commands:' 1>&2
    echo ' log glue               glueコンテナのログを表示する' 1>&2
    echo ' log trino              trinoコンテナのログを表示する' 1>&2
    echo ' log hive_metastore     hive_metastoreコンテナのログを表示する' 1>&2
    echo ' log minio              minioコンテナのログを表示する' 1>&2
}

log "$@"