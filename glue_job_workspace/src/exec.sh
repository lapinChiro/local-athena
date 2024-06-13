#! /bin/sh

docker run -it -v ./.aws:/home/glue_user/.aws -v ./glue_job_workspace/:/home/glue_user/workspace/ -e DISABLE_SSL=true --rm -p 4040:4040 -p 18080:18080 --name glue_spark_submit amazon/aws-glue-libs:glue_libs_4.0.0_image_01 spark-submit /home/glue_user/workspace/src/main.py
