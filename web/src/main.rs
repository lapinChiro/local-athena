use axum::{response::Html, routing::get, Router};
use prusto::{auth::Auth, ClientBuilder, Presto};

#[derive(Presto, Debug)]
struct Foo {
    a: i64,
    b: f64,
    c: String,
}

#[tokio::main]
async fn main() {
    let app = Router::new().route("/", get(handler));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3511").await.unwrap();

    axum::serve(listener, app).await.unwrap();
}

async fn handler() -> Html<&'static str> {
    request().await;
    Html("<h1>Hello, world!</h1>")
}

async fn request() {
    let built_client = ClientBuilder::new("user", "trino")
        .port(8080)
        .catalog("minio")
        .schema("default")
        .auth(Auth::new_basic("username", None::<String>))
        .build();
    let cli = match built_client {
        Ok(c) => c,
        Err(e) => {
            println!("{e}");
            panic!("pani")
        }
    };

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
