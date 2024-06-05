#!/bin/sh

cat ./postgres/table/tasks.sql > ./postgres/prepare.sql
cat ./postgres/stored/get_set_update_pending_task.sql >> ./postgres/prepare.sql
cat ./postgres/stored/get_task.sql >> ./postgres/prepare.sql
cat ./postgres/stored/set_insert_task.sql >> ./postgres/prepare.sql
cat ./postgres/stored/set_update_task_result.sql >> ./postgres/prepare.sql

./cli/postgres.sh -f ./postgres/prepare.sql

