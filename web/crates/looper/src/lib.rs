use resident_utils::postgres::deadpool_postgres::tokio_postgres::Client;
use resident_utils::{ctrl_c_handler, postgres::make_worker, LoopState};
use serde_json::{json, Value};
use std::time::Duration;
use uuid::Uuid;

use postgres::{get_postgres_pool, Task};
use trino::client::simple_request;
mod error;

async fn get_task(pg_conn: &Client) -> Result<Vec<Task>, error::Error> {
    let res = postgres::set_get_pending_task(pg_conn).await?;
    Ok(res)
}

async fn set_finish_task(
    pg_conn: &Client,
    task_uuid: &Uuid,
    query_result: Value,
    result_stauts: String,
) -> Result<Vec<Task>, error::Error> {
    let res = postgres::set_finish_task(pg_conn, task_uuid, query_result, result_stauts).await?;
    Ok(res)
}

async fn process_query_statement(
    query_statement: &Option<String>,
    task_uuid: &Option<Uuid>,
    pg_client: &Client,
) -> Result<(), error::Error> {
    if query_statement.is_none() || task_uuid.is_none() {
        return Err(error::Error::InvalidTask);
    };

    match simple_request(query_statement.clone().unwrap().as_str()).await {
        Ok(response) => {
            set_finish_task(
                pg_client,
                &task_uuid.unwrap(),
                json!({"result": response}),
                "succeeded".to_owned(),
            )
            .await?;
        }
        Err(e) => {
            set_finish_task(
                pg_client,
                &task_uuid.unwrap(),
                json!({"error" : format!("Trino Err, {e}")}),
                "failed".to_owned(),
            )
            .await?;
        }
    }

    Ok(())
}

pub async fn run() -> Result<(), error::Error> {
    let pg_pool = get_postgres_pool()?;

    #[allow(clippy::let_underscore_future)]
    let (_, token) = ctrl_c_handler();

    let handles = vec![make_worker(
        pg_pool.clone(),
        token.clone(),
        Duration::from_secs(10),
        |_now, pg_client| async move {
            let pg_client = match pg_client {
                Ok(client) => client,
                Err(e) => {
                    println!("pg_client error={}", e);
                    return LoopState::Duration(Duration::from_secs(60));
                }
            };
            match get_task(&pg_client).await {
                Ok(task) => {
                    if task.is_empty() {
                        LoopState::Duration(Duration::from_secs(1))
                    } else {
                        println!("task={:?}", task);
                        let _ = process_query_statement(
                            &task[0].query_statement,
                            &task[0].uuid,
                            &pg_client,
                        )
                        .await
                        .map_err(|e| println!("process_query_statement_error: {e}"));
                        LoopState::Continue
                    }
                }
                Err(e) => {
                    println!("get_task error={}", e);
                    LoopState::Duration(Duration::from_secs(60))
                }
            }
        },
        |_| async move {
            println!("graceful stop worker 1");
        },
    )];

    for handle in handles {
        handle.await?;
    }
    Ok(())
}
