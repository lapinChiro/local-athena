use axum::{extract, response::Json};
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
pub struct TrinoResponse {
    result: trino::query_result::QueryResult,
    sql: String,
}

#[derive(Deserialize)]
pub struct Request {
    sql: String,
}

pub async fn handler(extract::Json(request): extract::Json<Request>) -> Json<TrinoResponse> {
    let result = trino::client::simple_request(&request.sql).await;
    match result {
        Ok(result) => Json(TrinoResponse {
            sql: request.sql,
            result,
        }),
        Err(e) => Json(TrinoResponse {
            sql: request.sql,
            result: trino::query_result::QueryResult {
                headers: vec!["error".to_owned()],
                rows: vec![vec![format!("{}", e).into()]],
            },
        }),
    }
}
