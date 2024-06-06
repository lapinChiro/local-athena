use prusto::{Client, Row};
use serde_json::Value;

pub async fn request(client: Client, sql: &str) -> anyhow::Result<Vec<Vec<Value>>> {
    println!("{sql}");
    let result: Vec<Row> = client.get_all::<Row>(sql.into()).await?.into_vec();

    let result_2 = client.get_all::<Row>(sql.into()).await?.split();
    println!("{:#?}", result_2);
    Ok(result.iter().map(|row| row.clone().into_json()).collect())
}
