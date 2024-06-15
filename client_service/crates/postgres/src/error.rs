use resident_utils::postgres::deadpool_postgres::{tokio_postgres, CreatePoolError};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error("CreatePoolError {0}")]
    CreatePoolError(#[from] CreatePoolError),

    #[error("TokioPostgres {0}")]
    TokioPostgres(#[from] tokio_postgres::Error),

    #[error("Json {0}")]
    Json(#[from] serde_json::Error),

    #[error("CreateTask")]
    CreateTask,

    #[error("InvalidTask")]
    InvalidTask,
}
