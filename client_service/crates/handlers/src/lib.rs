mod error;
mod execute_sql_async;
mod execute_sql_sync;
mod job_status;
mod root;

use axum::{
    routing::{get, post},
    Router,
};

pub async fn make_router() -> Result<(), error::Error> {
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3511").await?;
    let router = build_router();

    axum::serve(listener, router).await?;

    Ok(())
}

fn build_router() -> Router {
    Router::new()
        .route("/", get(root::handler))
        .route("/execute_sql_sync", post(execute_sql_sync::handler))
        .route("/execute_sql_async", post(execute_sql_async::handler))
        .route("/job_status", post(job_status::handler))
}
