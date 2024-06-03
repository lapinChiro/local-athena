use prusto::{Client, Row};
use serde_json::Value;

pub async fn request(client: Client, sql: &str) -> Vec<Vec<Value>> {
    println!("{sql}");
    let result: Vec<Row> = client.get_all::<Row>(sql.into()).await.unwrap().into_vec();

    result.iter().map(|row| row.clone().into_json()).collect()
}
