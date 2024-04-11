#!/usr/bin/bash



# Prompt user for database and server details
read -rp "Enter database name (use your RDS database name): " DB_NAME
echo
read -rp "Enter database admin user (use your RDS database username): " DB_USER
echo
read -rp "Enter database admin password (use your RDS database password): " DB_PASSWORD
echo
read -rp "Enter database host (use your RDS database endpoint without port, which looks like xxxxx.amazonaws.com): " DB_HOST
echo
read -rp "Enter Redis host (use your Redis endpoint, e.g., xxxxx.cache.amazonaws.com): " REDIS_HOST
echo
read -rp "Enter Redis port (default 6379): " REDIS_PORT
echo
read -rp "Enter public DNS of EC2 instance for the server configuration, which looks like xxxxx.compute-1.amazonaws.com: " EC2_DNS
echo

# Set WordPress path
WP_PATH="/var/www/html/wordpress"
USER="www-data"
# Function to handle MySQL configuration errors
handle_mysql_error() {
    printf "Failed to configure MySQL database and user.\\n" >&2
    return 1
}

# Install required packages
install_packages() {
    if ! sudo apt-get update || ! sudo apt-get upgrade -y; then
        printf "Failed to update and upgrade system packages.\\n" >&2
        return 1
    fi

    local packages="php8.1-fpm php8.1-mysql php8.1-redis nginx mysql-server redis-server"
    if ! sudo apt-get install -y --no-install-recommends $packages; then
        printf "Failed to install required packages.\\n" >&2
        return 1
    fi

    if ! sudo wget -q https://wordpress.org/wordpress-6.5.2.tar.gz -O - | sudo tar -xz -C /var/www/html; then
        printf "Failed to download and extract WordPress.\\n" >&2
        return 1
    fi

    sudo chown -R $USER:$USER $WP_PATH
    sudo chmod -R 755 $WP_PATH
}

# Configure MySQL
configure_mysql() {
    local mysql_cmd="mysql -h $DB_HOST -P 3306 -u $DB_USER -p$DB_PASSWORD"
    if ! $mysql_cmd <<-EOF
  CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';
  GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
  FLUSH PRIVILEGES;
EOF


    then
        handle_mysql_error
    fi
}

# Configure PHP
configure_php() {
    local config_file="/etc/php/8.1/fpm/php.ini"

    # Create a backup of the original configuration file
    cp "$config_file" "$config_file.bak" || { printf "Failed to create backup for PHP configuration.\\n" >&2; return 1; }

    # Update PHP settings
    local settings="s/error_reporting = .*/error_reporting = E_ALL/;s/display_errors = .*/display_errors = On/;s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/;s/memory_limit = .*/memory_limit = 512M/"
    if ! sudo sed -i "$settings" "$config_file"; then
        printf "Failed to update PHP configuration settings.\\n" >&2
        return 1
    fi
}

# Configure Redis
configure_redis() {
    local wp_config="$WP_PATH/wp-config.php"

    if [ ! -f "$wp_config" ]; then
        printf "WordPress config file does not exist.\\n" >&2
        return 1
    fi

    # Set Redis cache settings
    local redis_host="$REDIS_HOST" # Change this to your Redis endpoint
    local redis_port="$REDIS_PORT" # Default Redis port, change if different

    # Adding Redis configuration to wp-config.php
    {
        echo "define('WP_REDIS_HOST', '$redis_host');"
        echo "define('WP_REDIS_PORT', '$redis_port');"
        echo "define('WP_CACHE_KEY_SALT', 'wp_$(date +%s)');"
        echo "define('WP_CACHE', true);"
    } >> "$wp_config"

    printf "Redis configuration for WordPress updated successfully.\\n"
}

# Configure Nginx
configure_nginx() {
    local config_path="/etc/nginx/sites-available/wordpress"
    local enabled_path="/etc/nginx/sites-enabled/wordpress"
    if ! sudo tee "$config_path" > /dev/null <<EOF
server {
    listen 80;
    root    $WP_PATH;
    index  index.php index.html index.htm;
    server_name  $EC2_DNS;

    client_max_body_size 500M;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
         include snippets/fastcgi-php.conf;
         fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
         fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
         include fastcgi_params;
    }
}
EOF
    then
        printf "Failed to configure Nginx.\\n" >&2
        return 1
    fi

    if [ -L "$enabled_path" ]; then
        sudo rm "$enabled_path"
    fi

    if ! sudo ln -s "$config_path" "$enabled_path"; then
        printf "Failed to enable Nginx site configuration.\\n" >&2
        return 1
    fi

    if ! sudo systemctl reload nginx; then
        printf "Failed to reload Nginx.\\n" >&2
        return 1
    fi
}

# Main execution function
main() {
    install_packages || return 1
    configure_mysql || return 1
    configure_php || return 1
    configure_redis || return 1
    configure_nginx || return 1
    printf "Configuration completed successfully.\\n"
}

main "$@"
