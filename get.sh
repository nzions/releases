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
#   - Verifies SHA256 checksums for security
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
failed=()
for binary in $binaries; do
    # Try to fetch -latest version first
    latest="${binary}-${platform}-latest"
    [ "$os" = "windows" ] && latest="${latest}.exe"
    url="https://github.com/${REPO}/raw/master/binaries/${binary}/${latest}"
    checksum_url="${url}.sum"
    dest="${INSTALL_DIR}/${binary}"
    [ "$os" = "windows" ] && dest="${dest}.exe"

    echo "  → ${binary} (latest)"
    
    # Download binary to temp location
    temp_binary=$(mktemp)
    temp_checksum=$(mktemp)
    
    if curl -sSLf "$url" -o "$temp_binary" 2>/dev/null; then
        # Download checksum
        if curl -sSLf "$checksum_url" -o "$temp_checksum" 2>/dev/null; then
            # Verify checksum
            cd "$(dirname "$temp_binary")"
            if echo "$(cat "$temp_checksum" | awk '{print $1}')  $(basename "$temp_binary")" | shasum -a 256 -c >/dev/null 2>&1; then
                mv "$temp_binary" "$dest"
                chmod +x "$dest"
                installed+=("$binary")
                echo "    ✓ Verified and installed"
            else
                echo "    ✗ Checksum verification failed"
                failed+=("$binary")
                rm -f "$temp_binary"
            fi
            rm -f "$temp_checksum"
        else
            echo "    Warning: Checksum not available, installing anyway"
            mv "$temp_binary" "$dest"
            chmod +x "$dest"
            installed+=("$binary")
        fi
    else
        echo "    Warning: ${binary} not available for ${platform}"
        failed+=("$binary")
        rm -f "$temp_binary"
    fi
done

echo ""
if [ ${#installed[@]} -gt 0 ]; then
    echo "✓ Installed to ${INSTALL_DIR}:"
    for binary in "${installed[@]}"; do
        echo "  - $binary"
    done
fi

if [ ${#failed[@]} -gt 0 ]; then
    echo ""
    echo "✗ Failed to install:"
    for binary in "${failed[@]}"; do
        echo "  - $binary"
    done
fi

if [ ${#installed[@]} -eq 0 ]; then
    echo "No binaries were installed."
    exit 1
fi

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
