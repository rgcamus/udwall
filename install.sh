#!/bin/bash

# udwall Install Script

set -e

# Parse version argument (e.g., --v0.0.2)
VERSION="main"
if [ $# -gt 0 ] && [[ "$1" == --v* ]]; then
    VERSION="${1#--}"  # Remove leading --
fi

REPO_URL="https://raw.githubusercontent.com/rgcamus/udwall/$VERSION"
INSTALL_PATH="/usr/local/bin/udwall"
CONFIG_DIR="/etc/udwall"
CONFIG_FILE="$CONFIG_DIR/udwall.yaml"

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "❌ Please run as root (sudo ./install.sh)"
        exit 1
    fi
}

check_dependencies() {
    echo "🔍 Checking dependencies..."
    local dependencies=("python3" "ufw" "curl")
    local missing=0

    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "❌ Error: $dep is not installed."
            echo "ℹ️  Please install $dep and try again."
            missing=1
        fi
    done

    if [ $missing -eq 1 ]; then
        exit 1
    fi
    echo "✅ Dependencies found."

    # Check for PyYAML
    if ! python3 -c "import yaml" &> /dev/null; then
        echo "⚠️  Warning: PyYAML (python3-yaml) not found."
        echo "ℹ️  Attempting to install it..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y python3-yaml
        elif command -v yum &> /dev/null; then
             yum install -y python3-yaml
        else
             echo "❌ Error: Could not install python3-yaml automatically. Please install it manually."
             exit 1
        fi
    fi
}

fetch_script() {
    echo "⬇️  Downloading udwall..."
    # Download udwall directly to /usr/local/bin/udwall
    if ! curl -fsSL "$REPO_URL/udwall" -o "$INSTALL_PATH"; then
        echo "❌ Error: Failed to download udwall from GitHub."
        echo "ℹ️  Please check your internet connection or if the repository/file exists."
        exit 1
    fi

    # Make executable
    echo "🔑 Setting permissions..."
    chmod +x "$INSTALL_PATH"
}

setup_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "⚙️  Setting up default configuration at $CONFIG_FILE"
        mkdir -p "$CONFIG_DIR"
        # Download default config
        if ! curl -fsSL "$REPO_URL/udwall.yaml.example" -o "$CONFIG_FILE"; then
             echo "⚠️  Warning: Failed to download default config. You may need to create one manually."
        fi
    else
        echo "⚠️  Configuration file already exists at $CONFIG_FILE. Skipping overwrite."
    fi
}

main() {
    echo "🚀 Installing udwall..."
    check_root
    check_dependencies
    fetch_script
    setup_config
    echo "✅ Installation complete!"
    echo "Run 'sudo udwall --help' to get started."
}

main
