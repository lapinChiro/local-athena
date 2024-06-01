use super::handlers;
use axum::{routing::get, Router};

pub async fn make_router() {
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3511").await.unwrap();
    let app = Router::new().route("/", get(handlers::root::handler));

    axum::serve(listener, app).await.unwrap();
}
