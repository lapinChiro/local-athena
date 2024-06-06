use crate::query_result::QueryResult;
use prusto::{Client, Row};

pub async fn request(client: Client, sql: &str) -> anyhow::Result<QueryResult> {
    println!("{sql}");

    let result = client.get_all::<Row>(sql.into()).await?.split();
    println!("{:#?}", result);
    let headers = result.0.iter().map(|row| row.0.clone()).collect();
    let rows = result.1.iter().map(|row| row.clone().into_json()).collect();
    Ok(QueryResult { headers, rows })
}
