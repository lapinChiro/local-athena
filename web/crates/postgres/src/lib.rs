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

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct Task {
    pub uuid: Option<Uuid>,
    pub query_statement: Option<String>,
    pub status: Option<String>,
    pub result: Option<Value>,
    pub created_at: Option<DateTime<Utc>>,
    pub updated_at: Option<DateTime<Utc>>,
}

pub fn get_postgres_pool() -> anyhow::Result<Pool> {
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
    anyhow::Ok(cfg.create_pool(Some(Tokio1), NoTls)?)
}

pub async fn set_task(client: &Client, query_statement: &str) -> anyhow::Result<Vec<Task>> {
    let sql = "SELECT to_jsonb(t1.*) FROM set_insert_task(p_query_statement := $1) AS t1;";
    let rows = execute(client, sql, &[&query_statement]).await?;

    anyhow::Ok(convert_task(rows))
}

pub async fn get_task(client: &Client, task_uuid: &Uuid) -> anyhow::Result<Vec<Task>> {
    let sql = "SELECT to_jsonb(t1.*) FROM get_task(p_uuid := $1) AS t1;";
    let rows = execute(client, sql, &[&task_uuid]).await?;

    anyhow::Ok(convert_task(rows))
}

pub async fn set_get_pending_task(client: &Client) -> anyhow::Result<Vec<Task>> {
    let sql = "SELECT to_jsonb(t1.*) FROM get_set_update_pending_task() AS t1;";
    let rows = execute(client, sql, &[]).await?;

    anyhow::Ok(convert_task(rows))
}

pub async fn set_finish_task(
    client: &Client,
    task_uuid: &Uuid,
    query_result: Value,
    result_stauts: String,
) -> anyhow::Result<Vec<Task>> {
    let sql = "SELECT to_jsonb(t1.*) FROM set_update_task_result(p_uuid := $1, p_result := $2, p_status := $3) AS t1;";
    println!("{:?}", query_result);
    let rows = execute(client, sql, &[&task_uuid, &query_result, &result_stauts]).await;

    match rows {
        Ok(r) => anyhow::Ok(convert_task(r)),
        Err(e) => {
            println!("PPPPPPP");
            panic!("{e}")
        }
    }
}

async fn execute(
    client: &Client,
    sql: &str,
    params: &[&(dyn ToSql + Sync)],
) -> anyhow::Result<Vec<Row>> {
    let res = client.query(sql, params).await;

    match res {
        Ok(r) => anyhow::Ok(r),
        Err(e) => {
            println!("NININI");
            panic!("{e}")
        }
    }
}

fn convert_task(rows: Vec<Row>) -> Vec<Task> {
    rows.into_iter()
        .map(|row| serde_json::from_value(row.get(0)).unwrap())
        .collect()
}
