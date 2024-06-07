mod check_job_status;
mod error;
mod execute_sql_async;
mod execute_sql_sync;
mod root;

use axum::{
    routing::{get, post},
    Router,
};

pub async fn make_router() {
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3511").await.unwrap();
    let router = build_router();

    axum::serve(listener, router).await.unwrap();
}

fn build_router() -> Router {
    Router::new()
        .route("/", get(root::handler))
        .route("/execute_sql_sync", post(execute_sql_sync::handler))
        .route("/execute_sql_async", post(execute_sql_async::handler))
        .route("/check_job_status", post(check_job_status::handler))
}
