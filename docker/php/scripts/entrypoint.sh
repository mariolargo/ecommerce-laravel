#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Running initialization tasks..."

# Task: Cache configuration and routes for faster performance
echo "Clearing and caching Laravel configuration and routes..."
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Task: Run database migrations automatically
echo "Running database migrations..."
php artisan migrate --force

# Create symbolic link for storage
php artisan storage:link

# Clear and optimize the application cache
echo "Optimizing cache..."
php artisan optimize:clear
php artisan optimize

echo "Initialization complete. Starting application..."

# Execute the CMD passed from the Dockerfile or docker run
exec "$@"