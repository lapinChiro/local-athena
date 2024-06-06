use resident_utils::postgres::deadpool_postgres::tokio_postgres::Client;
use resident_utils::{ctrl_c_handler, postgres::make_worker, LoopState};
use serde_json::{json, Value};
use std::time::Duration;
use uuid::Uuid;

use trino::client::simple_request;
use postgres::{get_postgres_pool, Task};

async fn get_task(pg_conn: &Client) -> anyhow::Result<Vec<Task>> {
    let res = postgres::set_get_pending_task(pg_conn).await?;
    Ok(res)
}

async fn set_finish_task(
    pg_conn: &Client,
    task_uuid: &Uuid,
    query_result: Value,
    result_stauts: String,
) -> anyhow::Result<Vec<Task>> {
    let res =
        postgres::set_finish_task(pg_conn, task_uuid, query_result, result_stauts).await;
    println!("set_finish_task");
    match res {
        Ok(r) => Ok(r),
        Err(e) => {
            println!("PANIPANI");
            panic!("{e}")
        }
    }
}

pub async fn run() -> anyhow::Result<()> {
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
                        match &task[0].query_statement {
                            Some(query_statement) => {
                                match simple_request(query_statement.as_str()).await {
                                    Ok(response) => {
                                        let pg_res = set_finish_task(
                                            &pg_client,
                                            &task[0].uuid.unwrap(),
                                            // serde_json::from_value(response.into()).unwrap(),
                                            json!({"result": response}),
                                            "succeeded".to_owned(),
                                        )
                                        .await;

                                        match pg_res {
                                            Ok(_) => {
                                                println!("finish task: {}", &task[0].uuid.unwrap())
                                            }
                                            Err(e) => panic!("PG Err, {e}"),
                                        }
                                    }
                                    Err(e) => {
                                        let _pg_res = set_finish_task(
                                            &pg_client,
                                            &task[0].uuid.unwrap(),
                                            json!({"error" : format!("Trino Err, {e}")}),
                                            "failed".to_owned(),
                                        )
                                        .await;
                                    }
                                }
                            }
                            None => panic!("invalid query_statement"),
                        }
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
        handle.await.unwrap();
    }
    Ok(())
}
