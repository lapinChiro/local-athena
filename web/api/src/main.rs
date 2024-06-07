use tokio::task::JoinHandle;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let abort_handle = run_looper().abort_handle();
    handlers::make_router().await;

    println!("abort_handle");
    abort_handle.abort();
    Ok(())
}

fn run_looper() -> JoinHandle<()> {
    tokio::spawn(async move {
        match looper::run().await {
            Ok(_) => println!("run looper: OK"),
            Err(e) => println!("run looper: Err {e}"),
        };
    })
}
