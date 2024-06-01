use api::handler;

mod api;
mod trino;

#[tokio::main]
async fn main() {
    handler::make_router().await;
}
