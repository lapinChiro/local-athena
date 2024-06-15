#! /bin/sh

docker compose exec -u 0 -it glue /home/glue_user/spark/bin/spark-submit /home/glue_user/workspace/src/main.py
