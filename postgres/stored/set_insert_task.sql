DROP TYPE IF EXISTS type_set_insert_task CASCADE;
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
$FUNCTION$ LANGUAGE plpgsql;