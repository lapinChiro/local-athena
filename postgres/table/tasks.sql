DROP TABLE IF EXISTS public.tasks;
CREATE TABLE public.tasks (
	uuid UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid()
	,query_statement TEXT NOT NULL
	,status TEXT NOT NULL
	,result jsonb DEFAULT NULL
	,created_at TIMESTAMPTZ NOT NULL DEFAULT now()
	,updated_at TIMESTAMPTZ DEFAULT now()
);
