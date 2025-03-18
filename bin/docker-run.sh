#!/bin/bash

# Clean up existing containers and network
echo "Cleaning up existing containers..."
docker stop rails_app postgres elasticsearch 2>/dev/null || true
docker rm rails_app postgres elasticsearch 2>/dev/null || true
docker network rm rails_network 2>/dev/null || true

# Create network
echo "Creating network..."
docker network create rails_network 2>/dev/null || true

# Start PostgreSQL
echo "Starting PostgreSQL..."
docker run -d \
  --name postgres \
  --network rails_network \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_USER=postgres \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:15.4

# Start Elasticsearch
echo "Starting Elasticsearch..."
docker run -d \
  --name elasticsearch \
  --network rails_network \
  -e "discovery.type=single-node" \
  -e "xpack.security.enabled=false" \
  -e "ES_JAVA_OPTS=-Xms1g -Xmx1g" \
  -e "cluster.name=docker-cluster" \
  -e "bootstrap.memory_lock=true" \
  -e "cluster.routing.allocation.disk.threshold_enabled=false" \
  -e "http.port=9200" \
  -e "network.host=0.0.0.0" \
  --ulimit nofile=65535:65535 \
  --ulimit memlock=-1:-1 \
  -p 9200:9200 \
  -v elasticsearch_data:/usr/share/elasticsearch/data \
  docker.elastic.co/elasticsearch/elasticsearch:7.17.10

# Wait for Elasticsearch with better health check
echo "Waiting for Elasticsearch..."
timeout=180  # 3 minutes timeout
start_time=$(date +%s)

while true; do
  if curl --silent --fail "http://localhost:9200/_cat/health" 2>/dev/null | grep -q "green\|yellow"; then
    echo "Elasticsearch is ready!"
    break
  fi

  current_time=$(date +%s)
  elapsed=$((current_time - start_time))
  
  if [ $elapsed -ge $timeout ]; then
    echo "Timeout waiting for Elasticsearch. Check logs:"
    docker logs elasticsearch
    exit 1
  fi

  printf '.'
  sleep 5
done

# Build and start Rails
echo "Building Rails application..."
docker build -t rails_app .

echo "Starting Rails application..."
docker run -it \
  --name rails_app \
  --network rails_network \
  -p 3000:3000 \
  -v $(pwd)/public/assets:/rails/public/assets \
  -v $(pwd)/public/packs:/rails/public/packs \
  -e RAILS_MASTER_KEY="2d25b929d3e4c9b2" \
  -e SECRET_KEY_BASE="2d25b929d3e4c9b2" \
  -e DATABASE_URL="postgresql://postgres:postgres@postgres:5432/study_abroad_production" \
  -e ELASTICSEARCH_URL="http://elasticsearch:9200" \
  -e RAILS_SERVE_STATIC_FILES="true" \
  -e RAILS_LOG_TO_STDOUT="true" \
  rails_app 