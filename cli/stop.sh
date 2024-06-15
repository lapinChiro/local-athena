#!/bin/sh

stop() {

    local subcommand=$1
    [ $# -gt 0 ] && shift
    case $subcommand in
    "glue") stop_service glue ;;
    "trino") stop_service trino ;;
    "hive-metastore") stop_service hive-metastore ;;
    "minio") stop_service minio ;;
    "client_service") stop_service client_service ;;
    "postgres") stop_service postgres ;;
    "all") stop_service ;;
    *) usage ;;
    esac
}

stop_service() {
    docker compose stop "$@"
}

usage() {
    echo 'Commands:' 1>&2
    echo ' stop glue               glueコンテナを停止する' 1>&2
    echo ' stop trino              trinoコンテナを停止する' 1>&2
    echo ' stop hive-metastore     hive-metastoreコンテナを停止する' 1>&2
    echo ' stop minio              minioコンテナを停止する' 1>&2
    echo ' stop client_service                client_serviceコンテナを停止する' 1>&2
    echo ' stop postgres           postgresコンテナを停止する' 1>&2
    echo ' stop all                全てのコンテナを停止する' 1>&2
}

stop "$@"
