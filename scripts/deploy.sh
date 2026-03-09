#!/bin/sh

set -e

# This script is executed by the PHP container's entrypoint at runtime.
# It only includes tasks that need to run in a live environment, such as DB migrations.

echo "Initializing deployment script..."

# Ensure required directories exist
echo "Ensuring required storage directories exist..."
mkdir -p /var/www/storage/logs
mkdir -p /var/www/storage/framework/cache/data
mkdir -p /var/www/storage/framework/sessions
mkdir -p /var/www/storage/framework/testing
mkdir -p /var/www/storage/framework/views
mkdir -p /var/www/bootstrap/cache

# Fix permissions for directories that might be mapped as host volumes or require writable state
echo "Fixing permissions for storage and bootstrap/cache..."
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Generate Laravel key if it's not provided via Coolify's environment variables
if [ -z "$APP_KEY" ]; then
    if [ ! -f "/var/www/.env" ]; then
        echo "Creating .env file from .env.example..."
        cp /var/www/.env.example /var/www/.env
    fi

    if grep -q "APP_KEY=$" "/var/www/.env" || ! grep -q "APP_KEY=" "/var/www/.env"; then
        echo "App key missing in .env. Attempting to generate..."
        php /var/www/artisan key:generate --force || echo "Failed to generate key."
    fi
fi

# Create database.sqlite if the connection is sqlite
if [ "$DB_CONNECTION" = "sqlite" ] || grep -q "^DB_CONNECTION=sqlite" "/var/www/.env" 2>/dev/null; then
    echo "SQLite connection detected. Ensuring database exists..."
    touch /var/www/database/database.sqlite
    chown www-data:www-data /var/www/database/database.sqlite
    chmod 664 /var/www/database/database.sqlite
    chown www-data:www-data /var/www/database
fi

# Run migrations
echo "Running migrations..."
php /var/www/artisan migrate --force || echo "Migrations failed. Database might not be ready yet."

# Create storage link
echo "Linking storage..."
php /var/www/artisan storage:link || true

# Cache configuration, routes, and views (essential for production performance)
echo "Caching configuration..."
php /var/www/artisan config:cache
echo "Caching routes..."
php /var/www/artisan route:cache
echo "Caching views..."
php /var/www/artisan view:cache

echo "Deployment steps completed successfully!"
