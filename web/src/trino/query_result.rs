use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Deserialize, Serialize)]
pub struct QueryResult {
    pub rows: Vec<Vec<Value>>,
    pub headers: Vec<String>,
}
