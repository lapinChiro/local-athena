use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error("Prusto {0}")]
    Prusto(#[from] prusto::error::Error),
}
