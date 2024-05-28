#!/bin/sh

browse() {
    local glue_url="http://localhost:8888"
    local minio_url="http://localhost:9001"

    local subcommand=$1; [ $# -gt 0 ] && shift
    case $subcommand in
        "glue"     ) open_browser $glue_url ;;
        "minio"    ) open_browser $minio_url ;;
        *          ) usage ;;
    esac
}

open_browser() {
    python -m webbrowser "$@"
}

usage() {
    echo 'Commands:' 1>&2
    echo '  browse glue         glue画面をデフォルトブラウザで開く' 1>&2
    echo '  browse minio        minioアドミン画面をデフォルトブラウザで開く' 1>&2
}

browse "$@"
