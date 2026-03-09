#!/bin/sh

set -e

# This script is executed by the PHP container's entrypoint at runtime.
# It only includes tasks that need to run in a live environment, such as DB migrations.

echo "Initializing deployment script..."

# Fix permissions for directories that might be mapped as host volumes or require writable state
echo "Fixing permissions for storage and bootstrap/cache..."
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Generate Laravel key if running locally and missing
if [ -f "/var/www/.env" ] && ! grep -q "APP_KEY=base64" "/var/www/.env"; then
    echo "App key missing in .env. Attempting to generate..."
    php /var/www/artisan key:generate || echo "Failed to generate key. Maybe no .env?"
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
