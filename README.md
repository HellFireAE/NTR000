# Ntara WordPress Code Challenge

Custom WordPress theme for a store/product grid layout, built on [Bedrock](https://roots.io/bedrock/) with a fully containerized local development environment.

## Local Development Setup

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine ≥ 28)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Start the environment

1. Clone the repository and open the folder in VS Code.
2. When prompted, click **Reopen in Container** — or run **Dev Containers: Reopen in Container** from the command palette.
3. VS Code will build and start four containers:

   | Container     | Purpose                     | Local URL             |
   | ------------- | --------------------------- | --------------------- |
   | `wp`          | PHP-FPM (WordPress runtime) | —                     |
   | `nginx`       | HTTPS reverse proxy         | https://localhost     |
   | `database`    | MariaDB 10.11               | `localhost:3307`      |
   | `adminer_csm` | Database UI                 | http://localhost:8081 |

4. The `postCreateCommand` will run automatically and:
   - Install PHP dependencies via Composer
   - Generate a self-signed SSL certificate for `localhost` (via `mkcert`)
   - Set up your `.env` file from `.env.example`

   > **SSL trust (optional):** Browsers will show a certificate warning on first visit. To suppress it, install the mkcert CA on your host machine:
   >
   > ```bash
   > mkcert -install
   > ```
   >
   > This is a one-time step per machine.

5. If nginx exits before the certificate is generated (first run only), restart it:
   ```bash
   docker restart <project>-nginx-1
   ```

### WordPress install

Visit **https://localhost** and complete the WordPress install wizard.

- **Database host:** `database`
- **Database name:** `wordpress`
- **Username:** `root`
- **Password:** `root`

After install, the admin dashboard is at **https://localhost/wp/wp-admin**.

### Database access

Adminer is available at **http://localhost:8081** — connect with:

- **Server:** `database`
- **Username:** `root`
- **Password:** `root`
- **Database:** `wordpress`

## Project Structure

```
.
├── .devcontainer/          # Docker Compose environment
│   ├── docker-compose.yml
│   ├── nginx/              # nginx config + SSL certs (gitignored)
│   ├── php/                # php.ini + php-fpm pool config
│   ├── mysql/              # MariaDB config + init SQL
│   └── scripts/            # init.sh, env-setup, git workflow helpers
├── config/
│   └── application.php     # Bedrock application config (loads .env)
├── web/
│   ├── app/
│   │   ├── themes/         # Custom theme lives here
│   │   ├── plugins/        # Managed via Composer
│   │   └── mu-plugins/     # Must-use plugins (bedrock autoloader, disallow-indexing)
│   └── wp/                 # WordPress core (managed via Composer, gitignored)
├── .env                    # Local environment config (gitignored)
├── .env.example            # Committed template
└── composer.json           # PHP dependency manifest
```

> **Note:** WordPress core (`web/wp`), uploads (`web/app/uploads`), and the `.env` file are all gitignored — they are generated/managed at runtime.

## Environment Variables

Copy `.env.example` to `.env` and adjust as needed. Key variables:

| Variable      | Default             | Description                         |
| ------------- | ------------------- | ----------------------------------- |
| `WP_ENV`      | `development`       | Environment name                    |
| `WP_HOME`     | `https://localhost` | Public site URL                     |
| `WP_SITEURL`  | `${WP_HOME}/wp`     | WordPress core URL (do not change)  |
| `DB_NAME`     | `wordpress`         | Database name                       |
| `DB_USER`     | `root`              | Database user                       |
| `DB_PASSWORD` | `root`              | Database password                   |
| `DB_HOST`     | `database`          | Database host (Docker service name) |

The `AUTH_KEY`, `SECURE_AUTH_KEY`, etc. fields should be filled with unique random strings from [roots.io/salts](https://roots.io/salts/).

## Privacy & Indexing

The `bedrock-disallow-indexing` must-use plugin is active in all non-production environments, which sets `X-Robots-Tag: noindex` on every response and configures `wp_head` to emit `<meta name="robots" content="noindex">`. The site will not be indexed by search engines in the `development` environment.
