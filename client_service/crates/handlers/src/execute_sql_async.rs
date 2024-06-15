use axum::{extract, response::Json};
use serde::{Deserialize, Serialize};

use uuid::Uuid;

#[derive(Serialize)]
pub struct SetJobResponse {
    task_uuid: Option<Uuid>,
    sql: String,
}

#[derive(Deserialize)]
pub struct Request {
    sql: String,
}

pub async fn handler(extract::Json(request): extract::Json<Request>) -> Json<SetJobResponse> {
    let pg_client = match postgres::get_postgres_pool() {
        Ok(pool) => match pool.get().await {
            Ok(client) => Some(client),
            Err(e) => {
                println!("{e}");
                None
            }
        },
        Err(e) => {
            println!("{e}");
            None
        }
    };
    if let Some(pg_client) = pg_client {
        match postgres::set_task(&pg_client, &request.sql).await {
            Ok(task) => Json(SetJobResponse {
                sql: request.sql,
                task_uuid: task.uuid,
            }),
            Err(e) => {
                println!("{e}");
                Json(SetJobResponse {
                    sql: request.sql,
                    task_uuid: None,
                })
            }
        }
    } else {
        Json(SetJobResponse {
            sql: request.sql,
            task_uuid: None,
        })
    }
}
