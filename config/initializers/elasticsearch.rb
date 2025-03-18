Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: ENV.fetch("ELASTICSEARCH_URL", "http://localhost:9200"),
  api_key: ENV.fetch("ELASTICSEARCH_API_KEY"),
  transport_options: { ssl: { verify: false } },
  log: true
)
