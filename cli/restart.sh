#!/bin/sh

restart() {

    local subcommand=$1
    [ $# -gt 0 ] && shift
    case $subcommand in
    "glue") restart_service glue ;;
    "trino") restart_service trino ;;
    "hive-metastore") restart_service hive-metastore ;;
    "minio") restart_service minio ;;
    "web") restart_service web ;;
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
    echo ' restart web                webコンテナを再起動する' 1>&2
}

restart "$@"
