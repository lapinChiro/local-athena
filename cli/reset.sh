#!/bin/sh

reset() {

    local subcommand=$1
    [ $# -gt 0 ] && shift
    case $subcommand in
    "hive-metastore") reset_catalog ;;
    "minio") reset_minio ;;
    "all") reset_all ;;
    *) usage ;;
    esac
}

reset_all() {
    reset_minio
    reset_catalog
}

reset_minio() {
    sudo rm -rf ./minio/data/.minio.sys
    sudo rm -rf ./minio/data/*
}

reset_catalog() {
  sudo rm -rf ./hive-metastore/work/metastore_db
}

usage() {
    echo 'Commands:' 1>&2
    echo ' reset hive-metastore     hive-metastoreのデータを消す' 1>&2
    echo ' reset minio              minioのデータを消す' 1>&2
    echo ' reset all                hive-metastoreとminioのデータを消す' 1>&2
}

reset "$@"
