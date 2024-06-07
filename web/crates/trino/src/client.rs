use crate::error::Error;
use crate::{query_result, sample_request, simple_request};
use prusto::{auth::Auth, Client, ClientBuilder};

fn build_client() -> Result<Client, Error> {
    let client = ClientBuilder::new("user", "trino")
        .port(8080)
        .catalog("minio")
        .schema("default")
        .auth(Auth::new_basic("username", None::<String>))
        .build()?;

    Ok(client)
}

pub async fn sample_request() -> Result<(), Error> {
    sample_request::request(build_client()?).await
}

pub async fn simple_request(sql: &str) -> Result<query_result::QueryResult, Error> {
    simple_request::request(build_client()?, sql).await
}
