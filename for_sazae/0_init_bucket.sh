# /bin/sh

export AWS_ACCESS_KEY_ID=minioadmin
export AWS_SECRET_ACCESS_KEY=minioadmin
export AWS_DEFAULT_REGION=ap-northeast-1
export MINIO_ENDPOINT=http://localhost:9000

aws s3 mb --endpoint-url $MINIO_ENDPOINT s3://trino-bucket
aws s3 sync --endpoint-url $MINIO_ENDPOINT ./sample_data/input s3://trino-bucket/input
