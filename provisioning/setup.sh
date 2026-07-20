#!/bin/bash

set -e

# Before cloning the repo:
# chmod 400 private.pem
# ssh -i private.pem ubuntu@<YOUR-COPIED-PUBLIC-IPv4-ADDRESS>

# Connected via SSH:
# cd ~/.ssh && ssh-keygen -t ed25519 -C "mlargo@example.com"
# cat ~/.ssh/id_ed25519.pub
# Add this key to GitHub Settings
# ec2-ssh> sudo mkdir -p /var/www && mkdir -p ~/public_html && cd ~/public_html
# ec2-ssh> git clone https://github.com ecommerce-laravel
# ec2-ssh> sudo ln -s ~/public_html/ecommerce-laravel/src /var/www/ecommerce-laravel
# ec2-ssh> sudo cp ~/public_html/ecommerce-laravel/provisioning/setup.sh /usr/local/bin/
# ec2-ssh> sudo chmod 755 /usr/local/bin/setup.sh 
# Custom prompt:
# nano ~/.bashrc
# Append the following code:
#
#   # Extract the current Git branch name
#   parse_git_branch() {
#     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
#   }
#
#   export PS1="\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "
# Reload command-line: source ~/.bashrc
# ec2-ssh> bash setup.sh

echo "Installing base packages and services..."
sudo apt update
sudo apt install -y --update acl libpq-dev libonig-dev libssl-dev libxml2-dev libcurl4-openssl-dev libicu-dev libzip-dev libfcgi-bin procps nginx git curl zip unzip nodejs npm software-properties-common 
sudo apt autoremove -y && sudo apt clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx --no-pager

echo "Installing PHP-FPM extensions..."
PHP_INI_DIR="/etc/php/8.5/fpm"
sudo apt update
sudo apt install -y --update php8.5 php8.5-cli php8.5-fpm php8.5-mbstring php8.5-bcmath php8.5-mysql php8.5-pgsql php8.5-sqlite3 php8.5-common php8.5-intl php8.5-xml php8.5-curl php8.5-zip php8.5-gd php8.5-redis php8.5-soap
sudo apt autoremove -y && sudo apt clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

sudo cp ~/public_html/ecommerce-laravel/docker/php/conf.d/opcache.ini "$PHP_INI_DIR/conf.d/"
sudo cp ~/public_html/ecommerce-laravel/docker/php/pool.d/z-overrides2.conf "$PHP_INI_DIR/pool.d/"

sudo systemctl start php8.5-fpm
sudo systemctl enable php8.5-fpm
sudo systemctl status php8.5-fpm --no-pager
php -v
sudo systemctl stop nginx
sudo cp ~/public_html/ecommerce-laravel/docker/proxy/sites-available/site.conf /etc/nginx/sites-available/
sudo nginx -t
sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/default
sudo systemctl reload nginx

echo "Installing Composer..."
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

echo "Installing Application..."
cd ~/public_html/ecommerce-laravel/src
composer install --no-dev --optimize-autoloader --no-interaction --no-progress --prefer-dist
composer dump-autoload
npm install
npm run build

echo "Creating additional folders and files..."
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
touch storage/logs/laravel.log

echo "Setting permissions..."
sudo chmod -R 775 storage bootstrap/cache
sudo chmod 777 storage/logs/laravel.log
sudo chown -R $USER:www-data ~/public_html/ecommerce-laravel
sudo chown -R $USER:www-data storage bootstrap/cache
sudo setfacl -R -d -m g::rwx storage && setfacl -R -d -m g::rwx bootstrap/cache

echo "Setting environment variables..."
cp .env.example .env
# Variables from AWS Secrets
# These are for testing
DB_CONN=mysql
DB_HOST=db-laravel.c5eo26ysg0xx.us-east-2.rds.amazonaws.com
DB_DATABASE=db-laravel
DB_USERNAME=admin
DB_PASSWORD=FGZXWZDSHuiSN8n
sed -i 's/APP_DEBUG=true/APP_DEBUG=false/g' .env
sed -i 's/APP_ENV=local/APP_ENV=production/g' .env
sed -i "s/DB_CONNECTION=mysql/DB_CONNECTION=${DB_CONN}/g" .env
sed -i "s/# DB_HOST=db/DB_HOST=${DB_HOST}/g" .env
sed -i "s/# DB_PORT=3306/DB_PORT=3306/g" .env
sed -i "s/# DB_DATABASE=laravel/DB_DATABASE=${DB_DATABASE}/g" .env
sed -i "s/# DB_USERNAME=root/DB_USERNAME=${DB_USERNAME}/g" .env
sed -i "s/# DB_PASSWORD=password/DB_PASSWORD=${DB_PASSWORD}/g" .env

echo "Creating database tables..."
php artisan key:generate
php artisan migrate

echo "Provisioning of EC2 completed!!"