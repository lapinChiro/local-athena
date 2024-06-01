use super::super::super::trino::client;
use axum::response::Html;

pub async fn handler() -> Html<&'static str> {
    client::sample_request().await;
    Html("<h1>Hello, world!</h1>")
}
