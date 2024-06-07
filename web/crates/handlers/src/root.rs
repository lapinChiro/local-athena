use axum::response::Html;
use trino::client;

pub async fn handler() -> Html<&'static str> {
    client::sample_request().await;
    Html("<h1>Hello, world!</h1>")
}
