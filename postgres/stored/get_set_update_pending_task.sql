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
$FUNCTION$ LANGUAGE plpgsql;