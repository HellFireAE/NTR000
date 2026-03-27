#!/bin/bash
# .devcontainer/scripts/git-credentials.sh
# Allows signed git changes from within the devcontainer
set -e

# Authenticate with GitHub CLI if available
if ! gh --version > /dev/null 2>&1; then
  echo "[ERROR] GitHub CLI (gh) is not installed. Please install it for official GitHub authentication."
  exit 1
fi

echo "[INFO] Authenticating with GitHub CLI..."

# Check if already authenticated
if ! gh auth status > /dev/null 2>&1; then
	gh auth login --hostname github.com --web --git-protocol https -s admin:public_key,admin:ssh_signing_key,user
fi

# Set git user.name and user.email from GitHub CLI if not set
GIT_NAME=$(git config --global user.name || true)
GIT_EMAIL=$(git config --global user.email || true)

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
	set +e
	GH_USER=$(gh api user --jq .login 2>/dev/null)
	GH_EMAIL=$(gh api user/emails --jq '.[] | select(.primary==true and .verified==true) | .email' 2>&1)
	set -e

	if echo "$GH_EMAIL" | grep -q 'This API operation needs the "user" scope'; then
		echo "[ERROR] GitHub CLI token is missing the 'user' scope required to fetch your email."
		echo "Run: gh auth refresh -h github.com -s user"
		exit 1
	fi

	# Only set if we got a valid email
	if [ -n "$GH_USER" ] && [ -z "$GIT_NAME" ]; then
		git config --global user.name "$GH_USER"
	fi

	if [ -n "$GH_EMAIL" ] && [[ ! "$GH_EMAIL" =~ 'API operation needs' ]] && [ -z "$GIT_EMAIL" ]; then
		git config --global user.email "$GH_EMAIL"
	fi
fi

echo "✅ GitHub CLI authentication is set up for $(git config --global user.name) <$(git config --global user.email)>"

# Add all public keys in .ssh as authentication and signing keys if not already present
for PUBKEY in .ssh/*.pub; do
	if [ -f "$PUBKEY" ]; then
		PUBKEY_CONTENT=$(cat "$PUBKEY")

		echo "[INFO] Checking GitHub for existing authentication key..."
		gh ssh-key add "$PUBKEY" --title "Auth Key: $(basename $PUBKEY)" --type authentication || true

		echo "[INFO] Checking GitHub for existing signing key..."
		gh ssh-key add "$PUBKEY" --title "Signing Key: $(basename $PUBKEY)" --type signing || true
	fi
done

# Generate or update Composer auth.json with the GitHub token from gh CLI
GH_TOKEN=$(gh auth token 2>/dev/null)
if [ -n "$GH_TOKEN" ]; then
	# Export GITHUB_TOKEN for Claude Code MCP and other tools
	export GITHUB_TOKEN="$GH_TOKEN"

	# Persist GITHUB_TOKEN to /etc/environment for all future sessions
	if ! grep -q "^GITHUB_TOKEN=" /etc/environment 2>/dev/null; then
		echo "GITHUB_TOKEN=$GH_TOKEN" >> /etc/environment
		echo "[INFO] Added GITHUB_TOKEN to /etc/environment for persistent access."
	else
		# Update existing GITHUB_TOKEN in /etc/environment
		sed -i "s|^GITHUB_TOKEN=.*|GITHUB_TOKEN=$GH_TOKEN|" /etc/environment
		echo "[INFO] Updated GITHUB_TOKEN in /etc/environment."
	fi

else
	echo "[WARN] Could not retrieve GitHub token from gh CLI. GitHub authentication may not work properly."
fi

echo "✅ Git/GitHub initialized."
