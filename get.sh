#!/bin/bash
#
# get.sh - Interactive installer for nzions/releases binaries
#
# USAGE:
#   curl -sSL https://raw.githubusercontent.com/nzions/releases/master/get.sh | bash
#
# FEATURES:
#   - Auto-detects OS and architecture (linux, darwin, windows)
#   - Supports amd64 and arm64 architectures
#   - Smart install directory selection:
#     1. Prioritizes ~/go/bin (Go standard)
#     2. Falls back to /usr/local/bin (system-wide)
#     3. Falls back to current directory
#   - Interactive binary selection menu
#   - Fetches latest versions from GitHub API
#   - Verifies downloads
#
# SUPPORTED PLATFORMS:
#   - linux/amd64, linux/arm64
#   - darwin/amd64, darwin/arm64
#   - windows/amd64
#

set -e

REPO="nzions/releases"

# Find best install directory from PATH
find_install_dir() {
    # Only use these supported locations
    local candidates=(
        "$HOME/go/bin"
        "/usr/local/bin"
        "./"
    )

    # First, check if any are already in PATH
    for dir in "${candidates[@]}"; do
        if echo "$PATH" | tr ':' '\n' | grep -q "^${dir}$"; then
            echo "$dir"
            return
        fi
    done

    # Otherwise, use first writable one
    for dir in "${candidates[@]}"; do
        if [ -w "$dir" ] || [ -w "$(dirname "$dir")" ]; then
            echo "$dir"
            return
        fi
    done

    # None available
    echo "Error: No supported install location available" >&2
    echo "Supported: ~/go/bin, /usr/local/bin, ./" >&2
    exit 1
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

installed=()
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
    installed+=("$binary")
done

echo ""
echo "✓ Installed to ${INSTALL_DIR}:"
for binary in "${installed[@]}"; do
    echo "  - $binary"
done

if echo "$PATH" | tr ':' '\n' | grep -q "^${INSTALL_DIR}$"; then
    echo ""
    echo "Run binaries directly:"
    for binary in "${installed[@]}"; do
        echo "  $binary --version"
    done
else
    echo ""
    echo "Not in PATH. Run with:"
    for binary in "${installed[@]}"; do
        if [ "$INSTALL_DIR" = "./" ]; then
            echo "  ./$binary --version"
        else
            echo "  ${INSTALL_DIR}/$binary --version"
        fi
    done
    echo ""
    echo "Or add to PATH:"
    echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
fi
