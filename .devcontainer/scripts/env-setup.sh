#!/bin/bash
set -e

# Only create the default .env file in the site directory for local development
SITE_ENV_EXAMPLE="./.env.example"
SITE_ENV_DEV_FILE="./.env"
UPDATE_HOSTNAME=0
if [ -f "$SITE_ENV_DEV_FILE" ]; then
  read -p "Site $SITE_ENV_DEV_FILE already exists. Overwrite? (y/n): " OVERWRITE_DEV
  if [[ "$OVERWRITE_DEV" =~ ^[Yy]$ ]]; then
    cp -f "$SITE_ENV_EXAMPLE" "$SITE_ENV_DEV_FILE"
    UPDATE_HOSTNAME=1
  else
    echo "Skipped overwriting $SITE_ENV_DEV_FILE."
  fi
else
  cp -f "$SITE_ENV_EXAMPLE" "$SITE_ENV_DEV_FILE"
  UPDATE_HOSTNAME=1
fi

# If overwriting or creating, set static DB vars and HOSTNAME
if [ $UPDATE_HOSTNAME -eq 1 ]; then
  chown $(id -u):$(id -g) "$SITE_ENV_DEV_FILE" 2>/dev/null || true
fi

# Convert .env file to LF endings
echo "Converting $SITE_ENV_DEV_FILE to LF line endings just in case..."
sed -i 's/\r$//' "$SITE_ENV_DEV_FILE"