#!/bin/bash
set -e

echo "Running database migration and reset..."
bundle exec rails db:migrate:reset
bundle exec rails db:seed
echo "Database reset complete!"
