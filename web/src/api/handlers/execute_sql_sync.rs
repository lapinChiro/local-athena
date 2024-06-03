use super::super::super::trino::client;
use axum::{extract, response::Json};
use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Serialize)]
pub struct TrinoResponse {
    result: Vec<Vec<Value>>,
    sql: String,
}

#[derive(Deserialize)]
pub struct Request {
    sql: String,
}

pub async fn handler(extract::Json(request): extract::Json<Request>) -> Json<TrinoResponse> {
    let result = client::simple_request(&request.sql).await;
    Json(TrinoResponse {
        sql: request.sql,
        result,
    })
}
