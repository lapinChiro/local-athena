require 'trino-client'

module TrinoClientWrapper
  class QueryExecutor
    def initialize
      @client = build_client
    end

    def build_client
      Trino::Client.new(
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
    end
  end

end
