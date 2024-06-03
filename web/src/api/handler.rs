use super::handlers;
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
        .route("/", get(handlers::root::handler))
        .route(
            "/execute_sql_sync",
            post(handlers::execute_sql_sync::handler),
        )
}
