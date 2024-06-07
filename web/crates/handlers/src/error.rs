use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error("Postgres {0}")]
    Postgres(#[from] postgres::error::Error),

    #[error("Json {0}")]
    Json(#[from] serde_json::Error),
}
