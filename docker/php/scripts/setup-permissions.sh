#!/bin/bash

STORAGE_DIR="/var/www/html/storage"
CACHE_DIR="/var/www/html/bootstrap/cache"

if [ ! -d "$STORAGE_DIR" ]; then
    echo "Error: Directory '$STORAGE_DIR' does not exist." >&2
    exit 1
fi

if [ ! -d "$CACHE_DIR" ]; then
    echo "Error: Directory '$CACHE_DIR' does not exist." >&2
    exit 1
fi

echo "Setting permissions..."
chmod -R 775 "$STORAGE_DIR" "$CACHE_DIR"
find /var/www/html -type d -exec chmod 775 {} \;
find /var/www/html -type f -exec chmod 664 {} \;
chmod 777 /var/www/html/storage/logs/laravel.log
echo "✓ Directories updated to 775."

echo "Setting owner..."
chown -R $USER:www-data /var/www/html
chown -R $USER:www-data "$STORAGE_DIR" "$CACHE_DIR"
chown www-data:www-data /var/www/html/storage/logs/laravel.log
echo "✓ Owner and group updated."

echo "Setting Access Control Lists (ACLs)..."
setfacl -R -d -m g::rwx "$STORAGE_DIR"
setfacl -R -d -m g::rwx "$CACHE_DIR"
echo "✓ ACLs updated."

echo "Permission updates completed successfully!"
