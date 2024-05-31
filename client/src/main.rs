use prusto::{ClientBuilder, Presto, auth::Auth};

#[derive(Presto, Debug)]
struct Foo {
    a: i64,
    b: f64,
    c: String,
}

#[tokio::main]
async fn main() {
    let cli = ClientBuilder::new("user", "localhost")
        .port(8080)
        .catalog("minio")
        .schema("default")
        .auth(Auth::new_basic("username", None::<String>))
        .build()
        .unwrap();

    println!("built");

    let sql = "select 1 as a, cast(1.1 as double) as b, 'bar' as c ";

    match cli.get_all::<Foo>(sql.into()).await {
        Ok(_r) => println!("OK"),
        Err(e) => {
            println!("{e}");
            panic!("PANIPANI")
        }
    }

    let data = cli.get_all::<Foo>(sql.into()).await.unwrap().into_vec();

    for r in data {
        println!("{:?}", r)
    }
}