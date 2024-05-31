require 'trino-client'

# create a client object:
client = Trino::Client.new(
  server: "localhost:8880",   # required option
  ssl: {verify: false},
  catalog: "native",
  schema: "default",
  user: "frsyuki",
  password: "********",
  time_zone: "US/Pacific",
  language: "English",
  properties: {
    "hive.force_local_scheduling": true,
    "raptor.reader_stream_buffer_size": "32MB"
  },
  http_proxy: "proxy.example.com:8080",
  http_debug: true
)

# run a query and get results as an array of arrays:
columns, rows = client.run("select * from sys.node")
rows.each {|row|
  p row  # row is an array
}

# run a query and get results as an array of hashes:
results = client.run_with_names("select alpha, 1 AS beta from tablename")
results.each {|row|
  p row['alpha']   # access by name
  p row['beta']
  p row.values[0]  # access by index
  p row.values[1]
}

# run a query and fetch results streamingly:
client.query("select * from sys.node") do |q|
  # get columns:
  q.columns.each {|column|
    puts "column: #{column.name}.#{column.type}"
  }

  # get query results. it feeds more rows until
  # query execution finishes:
  q.each_row {|row|
    p row  # row is an array
  }
end

# killing a query
query = client.query("select * from sys.node")
query_id = query.query_info.query_id
query.each_row {|row| ... }  # when a thread is processing the query,
client.kill(query_id)  # another thread / process can kill the query.

# Use Query#transform_row to parse Trino ROW types into Ruby Hashes.
# You can also set a scalar_parser to parse scalars how you'd like them.
scalar_parser = -> (data, type) { (type === 'json') ? JSON.parse(data) : data }
client.query("select * from sys.node") do |q|
  q.scalar_parser = scalar_parser

  # get query results. it feeds more rows until
  # query execution finishes:
  q.each_row {|row|
    p q.transform_row(row)
  }
end
