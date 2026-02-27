#!/bin/bash
# release.sh - Build and release binaries with go build

set -e

RELEASES_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARIES_FILE="$RELEASES_REPO/.binaries"

# Helpers
error() { echo "Error: $*" >&2; exit 1; }
log() { echo "$*"; }

# Platforms to build
PLATFORMS=("linux/amd64" "linux/arm64" "darwin/amd64" "darwin/arm64" "windows/amd64")

# Load binaries
if [ $# -gt 0 ]; then
    BINARIES=("$@")
else
    [ -f "$BINARIES_FILE" ] || error ".binaries file not found at $BINARIES_FILE"
    mapfile -t BINARIES < "$BINARIES_FILE"
fi

declare -a RELEASED

# Build each binary
log "Building binaries..."
for entry in "${BINARIES[@]}"; do
    # Parse path:appname format
    binary_path="${entry%:*}"
    binary_name="${entry#*:}"
    # If no appname specified, use basename of path
    [ "$binary_name" = "$entry" ] && binary_name=$(basename "$binary_path")
    
    # Expand ~ and validate
    binary_path="${binary_path/#\~/$HOME}"
    [ -d "$binary_path" ] || error "Path not found: $binary_path"
    
    log ""
    log "  → $binary_name"
    
    # Find go.mod by walking up
    mod_dir="$binary_path"
    while [ "$mod_dir" != "/" ] && [ ! -f "$mod_dir/go.mod" ]; do
        mod_dir=$(dirname "$mod_dir")
    done
    [ -f "$mod_dir/go.mod" ] || error "go.mod not found above: $binary_path"
    
    # Extract version
    rel_path="${binary_path#$mod_dir/}"
    version=$(cd "$mod_dir" && go run "./$rel_path" --version 2>/dev/null | head -1)
    version=$(echo "$version" | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    [ -n "$version" ] || error "Could not extract version from: $binary_path"
    [[ "$version" =~ ^v ]] || version="v$version"
    
    log "    version: $version"
    
    # Get git commit hash from source repo
    git_commit=$(cd "$mod_dir" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
    build_date=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    releaser_url="https://github.com/nzions/releases"
    license="Copyright (c) 2026 nzions. All rights reserved. Private and proprietary software. Use requires permission."
    
    # Build ldflags
    ldflags="-s -w"
    ldflags="$ldflags -X 'github.com/nzions/releases.gitCommit=$git_commit'"
    ldflags="$ldflags -X 'github.com/nzions/releases.buildDate=$build_date'"
    ldflags="$ldflags -X 'github.com/nzions/releases.url=$releaser_url'"
    ldflags="$ldflags -X 'github.com/nzions/releases.license=$license'"
    
    # Create output directory
    dest_dir="$RELEASES_REPO/binaries/$binary_name"
    mkdir -p "$dest_dir"
    
    # Build for each platform
    for platform in "${PLATFORMS[@]}"; do
        os="${platform%/*}"
        arch="${platform#*/}"
        
        # Map darwin to macos in output
        output_os="$os"
        [ "$os" = "darwin" ] && output_os="macos"
        
        target_name="$output_os-$arch-$version"
        target_path="$dest_dir/$target_name"
        
        # Build with injected variables
        cd "$mod_dir"
        CGO_ENABLED=0 GOOS="$os" GOARCH="$arch" go build \
            -tags netgo \
            -ldflags="$ldflags" \
            -o "$target_path" "./$rel_path" || continue
        chmod +x "$target_path"
    done
    
    RELEASED+=("$binary_name:$version")
done

# Commit, tag, and push
if [ ${#RELEASED[@]} -gt 0 ]; then
    log ""
    log "Committing and pushing..."
    cd "$RELEASES_REPO"
    
    # Build commit message
    msg="release:"
    for rel in "${RELEASED[@]}"; do
        msg="$msg ${rel%:*} ${rel#*:}"
    done
    
    git add -f -A
    git commit --no-verify -m "$msg"
    
    # Create tags and push
    for rel in "${RELEASED[@]}"; do
        git tag -f "${rel/:/-}"
    done
    
    git push --follow-tags
    
    log "✓ Done: $msg"
fi
