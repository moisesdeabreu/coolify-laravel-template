#!/bin/bash

# Navigate to the app directory
cd /var/www

# Install dependencies if composer.json exists
if [ -f composer.json ]; then
    echo "Installing dependencies..."
    composer install --no-interaction --optimize-autoloader --no-dev
fi

# Fix permissions
echo "Fixing permissions..."
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Generate Laravel key if missing
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
fi

if grep -q "APP_KEY=$" .env || ! grep -q "APP_KEY=" .env; then
    echo "Generating app key..."
    php artisan key:generate
fi

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Create storage link
echo "Linking storage..."
php artisan storage:link || true

# Cache configuration, routes, and views
echo "Caching configuration..."
php artisan config:cache
echo "Caching routes..."
php artisan route:cache
echo "Caching views..."
php artisan view:cache

echo "Deployment steps completed successfully!"
