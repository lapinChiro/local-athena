#!/bin/sh

log() {

    local subcommand=$1
    [ $# -gt 0 ] && shift
    case $subcommand in
    "glue") show_log glue ;;
    "trino") show_log trino ;;
    "hive-metastore") show_log hive-metastore ;;
    "minio") show_log minio ;;
    "client_service") show_log client_service ;;
    "postgres") show_log postgres ;;
    *) usage ;;
    esac
}

show_log() {
    docker compose logs -f "$@"
}

usage() {
    echo 'Commands:' 1>&2
    echo ' log glue               glueコンテナのログを表示する' 1>&2
    echo ' log trino              trinoコンテナのログを表示する' 1>&2
    echo ' log hive-metastore     hive-metastoreコンテナのログを表示する' 1>&2
    echo ' log minio              minioコンテナのログを表示する' 1>&2
    echo ' log client_service                client_serviceコンテナのログを表示する' 1>&2
    echo ' log postgres           postgresコンテナのログを表示する' 1>&2
}

log "$@"
