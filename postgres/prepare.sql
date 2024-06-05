DROP TABLE IF EXISTS tasks;
CREATE TABLE tasks (
	uuid UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid()
	,query_statement TEXT NOT NULL
	,status TEXT NOT NULL
	,result jsonb DEFAULT NULL
	,created_at TIMESTAMPTZ NOT NULL DEFAULT now()
	,updated_at TIMESTAMPTZ DEFAULT now()
);
DROP TYPE IF EXISTS type_get_set_update_pending_task CASCADE;
CREATE TYPE type_get_set_update_pending_task AS (
	uuid UUID
	,query_statement TEXT
	,status TEXT
	,result jsonb
	,created_at TIMESTAMPTZ
	,updated_at TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION get_set_update_pending_task(
  -- non params
) RETURNS SETOF type_get_set_update_pending_task AS $FUNCTION$
DECLARE
  w_task RECORD;
  w_uuid UUID;
BEGIN

  SELECT
    uuid
  INTO
    w_uuid
  FROM
    tasks
  WHERE
    status = 'pending'
  LIMIT
    1
  FOR UPDATE -- workerの並列実行をRDSの行ロックで調停するための条件
  ;

  UPDATE tasks SET
    status = 'running'
    ,updated_at = now()
  WHERE
    uuid = w_uuid
    AND status = 'pending' -- workerの並列実行をRDSの行ロックで調停するための条件
  RETURNING
    uuid
    ,query_statement
    ,status
    ,result
    ,created_at
    ,updated_at
  INTO
    w_task
  ;
  IF w_task.uuid IS NULL THEN
    RETURN;
  END IF;

  RETURN NEXT w_task;
END;
$FUNCTION$ LANGUAGE plpgsql;DROP TYPE IF EXISTS type_get_task CASCADE;
CREATE TYPE type_get_task AS (
	uuid UUID
	,query_statement TEXT
	,status TEXT
	,result jsonb
	,created_at TIMESTAMPTZ
	,updated_at TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION get_task(
  p_uuid UUID
) RETURNS SETOF type_get_task AS $FUNCTION$
DECLARE
BEGIN

  IF p_uuid IS NULL THEN
    RAISE 'uuid is null';
  END IF;

  RETURN QUERY
  SELECT
    uuid
    ,query_statement
    ,status
    ,result
    ,created_at
    ,updated_at
  FROM
    tasks
  WHERE
    uuid = p_uuid
  ;
END;
$FUNCTION$ LANGUAGE plpgsql;DROP TYPE IF EXISTS type_set_insert_task CASCADE;
CREATE TYPE type_set_insert_task AS (
  uuid UUID
  ,query_statement TEXT
  ,status TEXT
  ,result jsonb
  ,created_at TIMESTAMPTZ
  ,updated_at TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION set_insert_task(
  p_query_statement TEXT
) RETURNS SETOF type_set_insert_task AS $FUNCTION$
DECLARE
  w_record RECORD;
BEGIN

  -- バリデーション
  IF p_query_statement = '' OR p_query_statement IS NULL THEN
    RAISE 'EMPTY QUERY STATEMENT: %', p_query_statement;
  END IF;

  INSERT INTO tasks (
    uuid
    ,query_statement
    ,status
    ,result
    ,created_at
    ,updated_at
  ) VALUES (
    gen_random_uuid()
    ,p_query_statement
    ,'pending'
    ,NULL
    ,now()
    ,NULL
  ) 
  RETURNING
    uuid
    ,query_statement
    ,status
    ,result
    ,created_at
    ,updated_at
  INTO
    w_record
  ;
  RETURN NEXT w_record;

END;
$FUNCTION$ LANGUAGE plpgsql;DROP TYPE IF EXISTS type_set_update_task_result CASCADE;
CREATE TYPE type_set_update_task_result AS (
	uuid UUID
	,query_statement TEXT
	,status TEXT
	,result jsonb
	,created_at TIMESTAMPTZ
	,updated_at TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION set_update_task_result(
  p_uuid UUID
  ,p_result jsonb
  ,p_status TEXT
) RETURNS SETOF type_set_update_task_result AS $FUNCTION$
DECLARE
  w_task RECORD;
BEGIN

  PERFORM
  FROM
    tasks
  WHERE
    uuid = p_uuid
    AND status = 'running'
    AND result IS NULL
  ;
  IF NOT FOUND THEN
    RAISE 'NOT FOUND RUNNING TASK: %', p_uuid;
  END IF;

  UPDATE tasks SET
    status = p_status
    ,result = p_result
    ,updated_at = now()
  WHERE
    uuid = p_uuid
  RETURNING
    uuid
    ,query_statement
    ,status
    ,result
    ,created_at
    ,updated_at
  INTO
    w_task
  ;

  RETURN NEXT w_task;
END;
$FUNCTION$ LANGUAGE plpgsql;