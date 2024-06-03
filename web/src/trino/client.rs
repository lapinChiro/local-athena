use super::{sample_request, simple_request};
use prusto::{auth::Auth, Client, ClientBuilder};
use serde_json::Value;

fn build_client() -> Client {
    ClientBuilder::new("user", "trino")
        .port(8080)
        .catalog("minio")
        .schema("default")
        .auth(Auth::new_basic("username", None::<String>))
        .build()
        .unwrap()
}

pub async fn sample_request() {
    sample_request::request(build_client()).await
}

pub async fn simple_request(sql: &str) -> Vec<Vec<Value>> {
    simple_request::request(build_client(), sql).await
}
