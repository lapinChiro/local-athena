use super::super::super::looper_task::postgres;

use axum::{extract, response::Json};
use serde::{Deserialize, Serialize};

use uuid::Uuid;

#[derive(Serialize)]
pub struct SetJobResponse {
    task_uuid: Uuid,
    sql: String,
}

#[derive(Deserialize)]
pub struct Request {
    sql: String,
}

pub async fn handler(extract::Json(request): extract::Json<Request>) -> Json<SetJobResponse> {
    let pg_client = postgres::get_postgres_pool().unwrap().get().await.unwrap();
    let set_task = postgres::set_task(&pg_client, &request.sql).await.unwrap();
    let task = set_task.first().unwrap();
    let task_uuid = task.uuid.unwrap();
    Json(SetJobResponse {
        sql: request.sql,
        task_uuid,
    })
}
