use thiserror::Error;
use tokio::task::JoinError;

#[derive(Error, Debug)]
pub enum Error {
    #[error("Postgres {0}")]
    Postgres(#[from] postgres::error::Error),

    #[error("Json {0}")]
    Json(#[from] serde_json::Error),

    #[error("TokioJoinHandle {0}")]
    TokioJoinHandle(#[from] JoinError),
}
