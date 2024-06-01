use prusto::{Client, Presto};

#[derive(Presto, Debug)]
pub struct Field {
    a: i64,
    b: f64,
    c: String,
}

pub async fn request(client: Client) {
    let sql = "select 1 as a, cast(1.2 as double) as b, 'foo' as c ";
    let data = client
        .get_all::<Field>(sql.into())
        .await
        .unwrap()
        .into_vec();

    for r in data {
        println!("{:?}", r)
    }
}
