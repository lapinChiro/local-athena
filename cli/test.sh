#!/bin/sh

test() {

    local subcommand=$1
    local target_uuid=$2
    [ $# -gt 0 ] && shift
    case $subcommand in
    "execute_sql_sync") exec_execute_sql_sync ;;
    "execute_sql_async") exec_execute_sql_async ;;
    "check_job_status") exec_check_job_status $target_uuid ;;
    "root") exec_root ;;
    *) usage ;;
    esac
}

exec_execute_sql_sync() {
  curl -X POST -H "Content-Type: application/json" -d "{\"sql\":\"select 1 as a, cast(1.2 as double) as b, 'foo' as c \"}" 'http://localhost:3511/execute_sql_sync'
}

exec_execute_sql_async() {
  curl -X POST -H "Content-Type: application/json" -d "{\"sql\":\"SELECT * FROM minio.asahi.answers_00101 LIMIT 2 \"}" 'http://localhost:3511/execute_sql_async'
}

exec_check_job_status() {
  curl -X POST -H "Content-Type: application/json" -d "{\"task_uuid\":\"$@\"}" 'http://localhost:3511/check_job_status'
}

exec_root() {
  curl 'http://localhost:3511/'
}

usage() {
    echo 'Commands:' 1>&2
    echo ' test glue               glueコンテナのログを表示する' 1>&2
    echo ' test trino              trinoコンテナのログを表示する' 1>&2
    echo ' test hive-metastore     hive-metastoreコンテナのログを表示する' 1>&2
    echo ' test minio              minioコンテナのログを表示する' 1>&2
    echo ' test web                webコンテナのログを表示する' 1>&2
    echo ' test postgres           postgresコンテナのログを表示する' 1>&2
}

test "$@"
