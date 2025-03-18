# syntax=docker/dockerfile:1
FROM ruby:3.2.2-slim AS base

# Rails app lives here
WORKDIR /rails

# Set production environment with a proper 16-byte key
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    DATABASE_URL="postgresql://postgres:postgres@postgres:5432" \
    ELASTICSEARCH_URL="http://elasticsearch:9200" \
    SECRET_KEY_BASE="2d25b929d3e4c9b2" \
    RAILS_SERVE_STATIC_FILES="true" \
    NODE_ENV="production" \
    RAILS_LOG_TO_STDOUT="true"

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libpq-dev \
    postgresql-client \
    nodejs \
    npm \
    git \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Install yarn packages and compile assets
RUN yarn install --check-files
RUN bundle exec rake assets:precompile
RUN bundle exec rake assets:clean

# Final stage for app image
FROM base

# Create and switch to a non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Ensure the public/assets directory exists and is writable
RUN mkdir -p /rails/public/assets /rails/public/packs && \
    chown -R rails:rails /rails/public

# Copy entrypoint script
COPY bin/docker-entrypoint /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint

# Set ownership and permissions
RUN chown -R rails:rails /rails

# Switch to non-root user
USER rails

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
ENTRYPOINT ["docker-entrypoint"]
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]