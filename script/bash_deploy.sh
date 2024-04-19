#!/bin/bash

# Set environment variables from SSM to be used in the script
export EC2_DNS=$(aws ssm get-parameter --name "public_dns" --with-decryption --query "Parameter.Value" --output text)
export REDIS_HOST=$(aws ssm get-parameter --name "redis_endpoint" --with-decryption --query "Parameter.Value" --output text)
export DB_HOST=$(aws ssm get-parameter --name "db_endpoint" --with-decryption --query "Parameter.Value" --output text)
export DB_NAME=$(aws ssm get-parameter --name "db_name" --with-decryption --query "Parameter.Value" --output text)
export DB_USER=$(aws ssm get-parameter --name "db_username" --with-decryption --query "Parameter.Value" --output text)
export DB_PASSWORD=$(aws ssm get-parameter --name "db_password" --with-decryption --query "Parameter.Value" --output text)

# Set WordPress path
WP_PATH="/var/www/html/wordpress"

# Set WordPress config file path
WP_CONFIG="$WP_PATH/wp-config.php"

# Function to handle MySQL configuration errors
handle_mysql_error() {
    printf "Failed to configure MySQL database and user.\\n" >&2
    return 1
}

# Install required packages
install_packages() {
    if ! sudo apt-get update -y; then
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

    sudo cp $WP_PATH/wp-config-sample.php $WP_PATH/wp-config.php
    sudo chown -R www-data:www-data $WP_PATH
    sudo chmod -R 755 $WP_PATH
}

# Configure MySQL
configure_mysql() {
    local mysql_cmd="mysql -h $DB_HOST -P 3306 -u $DB_USER -p$DB_PASSWORD"
    if ! $mysql_cmd <<-EOF
  CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED WITH mysql_native_password BY '$DB_PASSWORD';
  GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';
  FLUSH PRIVILEGES;
EOF
    then
        handle_mysql_error
    fi
}

# Configure WordPress database
configure_wp_database() {
    if [ ! -f "$WP_CONFIG" ]; then
        printf "WordPress config file does not exist.\\n" >&2
        return 1
    fi
        # Update wp-config.php with the new database settings
        sed -i "s/define( 'DB_NAME', '.*' );/define( 'DB_NAME', '$DB_NAME' );/" $WP_CONFIG
        sed -i "s/define( 'DB_USER', '.*' );/define( 'DB_USER', '$DB_USER' );/" $WP_CONFIG
        sed -i "s/define( 'DB_PASSWORD', '.*' );/define( 'DB_PASSWORD', '$DB_PASSWORD' );/" $WP_CONFIG
        sed -i "s/define( 'DB_HOST', '.*' );/define( 'DB_HOST', '$DB_HOST' );/" $WP_CONFIG
              printf "Database configuration updated successfully.\\n"
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
    if [ ! -f $WP_CONFIG ]; then
        printf "WordPress config file does not exist.\\n" >&2
        return 1
    fi

    # Adding Redis configuration to wp-config.php
    {
        echo "define('WP_REDIS_HOST', '$REDIS_HOST');"
        echo "define('WP_REDIS_PORT', '$REDIS_PORT');"
        echo "define('WP_CACHE_KEY_SALT', 'wp_$(date +%s)');"
        echo "define('WP_CACHE', true);"
    } >> $WP_CONFIG

    printf "Redis configuration for WordPress updated successfully.\\n"
}
    sudo chown -R $USER:$USER $WP_PATH
    sudo chmod -R 755 $WP_PATH
# Configure Nginx
configure_nginx() {
    local config_path="/etc/nginx/sites-available/wordpress"
    local enabled_path="/etc/nginx/sites-enabled/wordpress"
    if ! sudo tee "$config_path" > /dev/null <<EOF
server {
    listen 80;
    root   $WP_PATH;
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
    configure_wp_database || return 1
    configure_php || return 1
    configure_redis || return 1
    configure_nginx || return 1
    printf "Configuration completed successfully.\\n"
}

main "$@"