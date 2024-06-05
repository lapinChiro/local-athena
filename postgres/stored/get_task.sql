DROP TYPE IF EXISTS type_get_task CASCADE;
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
$FUNCTION$ LANGUAGE plpgsql;