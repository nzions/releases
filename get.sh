#!/bin/bash
# get.sh - Install latest binaries
# Usage: curl -sSL https://raw.githubusercontent.com/nzions/releases/master/get.sh | bash

set -e

REPO="nzions/releases"

# Find best install directory from PATH
find_install_dir() {
    # Preferred locations in order
    local candidates=(
        "$HOME/go/bin"
        "/usr/local/bin"
        "$HOME/bin"
        "$HOME/.local/bin"
    )
    
    for dir in "${candidates[@]}"; do
        # Check if directory is in PATH
        if echo "$PATH" | tr ':' '\n' | grep -q "^${dir}$"; then
            echo "$dir"
            return
        fi
    done
    
    # Fallback: use first writable candidate
    for dir in "${candidates[@]}"; do
        if [ -w "$dir" ] || [ -w "$(dirname "$dir")" ]; then
            echo "$dir"
            return
        fi
    done
    
    # Last resort
    echo "$HOME/bin"
}

INSTALL_DIR=$(find_install_dir)

# Detect OS and arch
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)

case "$os" in
    darwin) os="macos" ;;
    linux) os="linux" ;;
    *) echo "Error: Unsupported OS: $os" >&2; exit 1 ;;
esac

case "$arch" in
    x86_64|amd64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) echo "Error: Unsupported architecture: $arch" >&2; exit 1 ;;
esac

platform="${os}-${arch}"

echo "Installing binaries for ${platform}..."
echo "Install directory: ${INSTALL_DIR}"
echo ""

mkdir -p "$INSTALL_DIR"

# Get list of binaries and install latest version of each
binaries=$(curl -sSL "https://api.github.com/repos/${REPO}/contents/binaries" | grep '"name"' | cut -d'"' -f4)

for binary in $binaries; do
    # Find latest version for this platform
    files=$(curl -sSL "https://api.github.com/repos/${REPO}/contents/binaries/${binary}" | grep '"name"' | cut -d'"' -f4)
    latest=$(echo "$files" | grep "^${platform}-v" | sort -V | tail -1)
    
    if [ -z "$latest" ]; then
        continue
    fi
    
    version="${latest#${platform}-}"
    url="https://github.com/${REPO}/raw/master/binaries/${binary}/${latest}"
    dest="${INSTALL_DIR}/${binary}"
    
    echo "  → ${binary} ${version}"
    curl -sSL "$url" -o "$dest"
    chmod +x "$dest"
done

echo ""
echo "✓ Done!"
if ! echo "$PATH" | grep -q "${INSTALL_DIR}"; then
    echo ""
    echo "Add to your PATH:"
    echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
fi
