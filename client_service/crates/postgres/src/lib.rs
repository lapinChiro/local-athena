use chrono::{DateTime, Utc};
use postgres_types::ToSql;
use resident_utils::postgres::deadpool_postgres::{
    tokio_postgres::{Client, NoTls, Row},
    Config, Pool, PoolConfig,
    Runtime::Tokio1,
    Timeouts,
};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::time::Duration;
use uuid::Uuid;

pub mod error;

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct Task {
    pub uuid: Option<Uuid>,
    pub query_statement: Option<String>,
    pub status: Option<String>,
    pub result: Option<Value>,
    pub created_at: Option<DateTime<Utc>>,
    pub updated_at: Option<DateTime<Utc>>,
}

pub fn get_postgres_pool() -> Result<Pool, error::Error> {
    let pool_config = PoolConfig {
        max_size: 2,
        timeouts: Timeouts {
            wait: Some(Duration::from_secs(2)),
            ..Default::default()
        },
        ..Default::default()
    };
    let cfg = Config {
        user: Some("multi".to_string()),
        password: Some("pass".to_string()),
        dbname: Some("postgres".to_string()),
        host: Some("postgres".to_string()),
        port: Some(5432),
        connect_timeout: Some(Duration::from_secs(5)),
        pool: Some(pool_config),
        ..Default::default()
    };
    Ok(cfg.create_pool(Some(Tokio1), NoTls)?)
}

pub async fn set_task(client: &Client, query_statement: &str) -> Result<Task, error::Error> {
    let sql = "SELECT to_jsonb(t1.*) FROM set_insert_task(p_query_statement := $1) AS t1;";
    let rows = execute(client, sql, &[&query_statement]).await?;

    if let Some(task) = convert_task(rows)?.first() {
        Ok(task.clone())
    } else {
        Err(error::Error::CreateTask)
    }
}

pub async fn get_task(client: &Client, task_uuid: &Uuid) -> Result<Task, error::Error> {
    let sql = "SELECT to_jsonb(t1.*) FROM get_task(p_uuid := $1) AS t1;";
    let rows = execute(client, sql, &[&task_uuid]).await?;

    let task = convert_task(rows)?;

    if task.len() == 0 {
        Ok(task.first().unwrap().clone())
    } else {
        Err(error::Error::InvalidTask)
    }
}

pub async fn set_get_pending_task(client: &Client) -> Result<Vec<Task>, error::Error> {
    let sql = "SELECT to_jsonb(t1.*) FROM get_set_update_pending_task() AS t1;";
    let rows = execute(client, sql, &[]).await?;

    convert_task(rows)
}

pub async fn set_finish_task(
    client: &Client,
    task_uuid: &Uuid,
    query_result: Value,
    result_stauts: String,
) -> Result<Vec<Task>, error::Error> {
    let sql = "SELECT to_jsonb(t1.*) FROM set_update_task_result(p_uuid := $1, p_result := $2, p_status := $3) AS t1;";
    println!("{:?}", query_result);
    let rows = execute(client, sql, &[&task_uuid, &query_result, &result_stauts]).await?;

    convert_task(rows)
}

async fn execute(
    client: &Client,
    sql: &str,
    params: &[&(dyn ToSql + Sync)],
) -> Result<Vec<Row>, error::Error> {
    let res = client.query(sql, params).await?;

    Ok(res)
}

fn convert_task(rows: Vec<Row>) -> Result<Vec<Task>, error::Error> {
    let tasks: Result<Vec<_>, _> = rows
        .into_iter()
        .map(|row| serde_json::from_value::<Task>(row.get(0)))
        .collect();

    tasks.map_err(|e| e.into())
}
