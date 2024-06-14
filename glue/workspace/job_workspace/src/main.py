import sys
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.sql.functions import explode, col, get_json_object, from_json
from pyspark.sql.types import StructType, StructField, StringType, ArrayType
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job

# パラメータの取得
# args = getResolvedOptions(sys.argv, ['JOB_NAME', 'INPUT_PATH', 'OUTPUT_PATH'])

# args = getResolvedOptions(sys.argv, ['JOB_NAME'])
args = {}
args['JOB_NAME'] = 'sample'
args['INPUT_PATH'] = 's3://asahi-data/input/'
args['OUTPUT_PATH'] = 's3://asahi-data/output/'

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)


# 入力データの読み込み
input_path = args['INPUT_PATH']
output_path = args['OUTPUT_PATH']

data = spark.read.format("csv").option("header", "true").option(
    "delimiter", "\t").option("escape", "\"").load(input_path)
df = data

# JSONスキーマを定義する
item_schema = StructType([
    StructField("type_kbn", StringType(), True),
    StructField("uuid", StringType(), True),
    StructField(
        "answer",
        StructType([
            StructField("uuid", StringType(), False),
            StructField("value", StringType(), False),
            StructField("uuids", ArrayType(StringType()), False)
        ]), True)
])

json_schema = StructType([
    StructField("items", ArrayType(item_schema), True),
    StructField("survey_uuid", StringType(), False)
])

df = df.withColumn("item_json_decoded",
                   from_json(col("item_json"), json_schema)).drop("item_json")
df = df.withColumn("survey_uuid", col("item_json_decoded.survey_uuid"))
df = df.withColumn("item", col("item_json_decoded.items"))
df = df.withColumn("item", explode(col("item_json_decoded.items")))
df = df.withColumn("item_uuid", col("item.uuid"))
df = df.withColumn("type_kbn", col("item.type_kbn"))
df = df.drop("item_json_decoded")

df.filter(col("type_kbn") == '00101')\
    .withColumn("option_uuids", col("item.answer.uuids")) \
    .select("uuid", "user_id_code", 'entried_at', 'survey_uuid', 'item_uuid', 'type_kbn', 'option_uuids') \
    .write.mode('overwrite').partitionBy('type_kbn', 'item_uuid', 'survey_uuid').parquet(f"{output_path}/large/00101")

df.filter(col("type_kbn") == '00102')\
    .withColumn("value", col("item.answer.value")) \
    .select("uuid", "user_id_code", 'entried_at', 'survey_uuid', 'item_uuid', 'type_kbn', 'value') \
    .write.mode('overwrite').partitionBy('type_kbn', 'item_uuid', 'survey_uuid').parquet(f"{output_path}/large/00102")

df.filter(col("type_kbn") == '00104')\
    .withColumn("value", col("item.answer.value")) \
    .select("uuid", "user_id_code", 'entried_at', 'survey_uuid', 'item_uuid', 'type_kbn', 'value') \
    .write.mode('overwrite').partitionBy('type_kbn', 'item_uuid', 'survey_uuid').parquet(f"{output_path}/large/00104")

df.filter(col("type_kbn") == '00105')\
    .withColumn("option_uuid", col("item.answer.uuid")) \
    .select("uuid", "user_id_code", 'entried_at', 'survey_uuid', 'item_uuid', 'type_kbn', 'option_uuid') \
    .write.mode('overwrite').partitionBy('type_kbn', 'item_uuid', 'survey_uuid').parquet(f"{output_path}/large/00105")

job.commit()
