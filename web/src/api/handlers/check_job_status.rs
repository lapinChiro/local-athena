use super::super::super::looper_task::postgres;

use axum::{extract, response::Json};
use serde::{Deserialize, Serialize};

use serde_json::Value;
use uuid::Uuid;

#[derive(Serialize)]
pub struct CheckJobResponse {
    task_uuid: Uuid,
    status: String,
    result: Value,
}

#[derive(Deserialize)]
pub struct Request {
    task_uuid: Uuid,
}

pub async fn handler(extract::Json(request): extract::Json<Request>) -> Json<CheckJobResponse> {
    println!("check_job_status: {:?}", request.task_uuid);
    let pg_client = postgres::get_postgres_pool().unwrap().get().await.unwrap();
    let get_task_result = postgres::get_task(&pg_client, &request.task_uuid)
        .await
        .unwrap();
    let task = get_task_result.first().unwrap();
    let task_uuid = task.clone().uuid.unwrap();
    let result = task.clone().result.unwrap();
    let status = task.clone().status.unwrap();
    Json(CheckJobResponse {
        status,
        task_uuid,
        result,
    })
}
