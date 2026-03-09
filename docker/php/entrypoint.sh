#!/bin/sh

set -e

# Set working directory
cd /var/www

# Run deployment tasks
echo "Running deployment tasks..."
sh /var/www/scripts/deploy.sh

# Start the main process (php-fpm)
echo "Starting main process: $@"
exec "$@"
