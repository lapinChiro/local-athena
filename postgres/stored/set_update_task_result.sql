DROP TYPE IF EXISTS type_set_update_task_result CASCADE;
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