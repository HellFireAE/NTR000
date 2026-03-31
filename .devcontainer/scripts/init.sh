#!/bin/bash
# .devcontainer/scripts/init.sh
# Devcontainer initialization script for an example WordPress Bedrock project

set -e

# Composer setup
composer config --global use-parent-dir true

# Move to the workspace folder
cd ${WORKSPACE_FOLDER:-/var/www/html}

# Set working directory
CSM_DIR=".devcontainer/scripts"

# .env setup — must run before composer install so post-install-cmd can reach the DB
bash $CSM_DIR/env-setup.sh

# Install PHP dependencies (triggers post-install-cmd → WordPress setup)
composer install --no-dev --optimize-autoloader

# Git workflow configuration
bash $CSM_DIR/git-workflow-setup.sh

# GitHub CLI setup
bash $CSM_DIR/git-credentials.sh

# SSL Certificate setup for local development (zero-config)
SSL_DIR=".devcontainer/nginx/ssl"

if [ ! -f "$SSL_DIR/localhost.pem" ]; then
    echo "[INFO] Generating local SSL certificate for localhost..."
    mkdir -p "$SSL_DIR"

    # Install mkcert CA
    mkcert -install

    # Generate certificate for localhost
    cd "$SSL_DIR"
    mkcert localhost 127.0.0.1 ::1
    cd - > /dev/null

    echo "[INFO] SSL certificate generated successfully!"
else
    echo "[INFO] SSL certificate already exists for localhost"
fi

echo "Initialization complete."
echo ""
echo "🌐 Your site is available at: https://localhost"
echo "✅ Zero configuration needed - SSL works automatically!"
