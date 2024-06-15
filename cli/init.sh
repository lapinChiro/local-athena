#!/bin/sh

docker compose run --entrypoint bash hive-metastore /opt/apache-hive-metastore/bin/schematool -initSchema -dbType derby
sudo chown -R 10000.root ./glue/workspace/jupyter_workspace
