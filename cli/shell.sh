#!/bin/sh

shell() {

    local subcommand=$1
    [ $# -gt 0 ] && shift
    case $subcommand in
    "glue") entry_shell glue ;;
    "trino") entry_shell trino ;;
    "hive-metastore") entry_shell hive-metastore ;;
    "minio") entry_shell minio ;;
    "client_service") entry_shell client_service ;;
    "postgres") entry_shell postgres ;;
    *) usage ;;
    esac
}

entry_shell() {
    docker compose exec -u 0 -it "$@" bash
}

usage() {
    echo 'Commands:' 1>&2
    echo ' shell glue               glueコンテナを再起動する' 1>&2
    echo ' shell trino              trinoコンテナを再起動する' 1>&2
    echo ' shell hive-metastore     hive-metastoreコンテナを再起動する' 1>&2
    echo ' shell minio              minioコンテナを再起動する' 1>&2
    echo ' shell  client_service               client_serviceコンテナを再起動する' 1>&2
    echo ' shell  postgres          postgresコンテナを再起動する' 1>&2
}

shell "$@"
