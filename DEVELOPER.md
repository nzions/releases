# Developer Guide

This document covers the technical details of building, releasing, and integrating with the releases system.

## Release Process

### Building Releases

```bash
bash release.sh
```

This script:
1. Reads binary paths from `.binaries`
2. Extracts version from `--version` output
3. Builds for 5 platforms (linux/arm64, linux/amd64, darwin/arm64, darwin/amd64, windows/amd64)
4. Injects build metadata via `-X` flags
5. Commits binaries and creates git tags
6. Pushes to GitHub

### Configuration

Edit `.binaries` (format: `path:appname`):

```
~/code/coreutils/certmania/cli:certmania
~/code/coreutils/simplecrypt/cli:simplecrypt
```

### Build Settings

Binaries are built with:
- `CGO_ENABLED=0` - Pure Go, no C dependencies
- `-tags netgo` - Pure Go network stack
- `-ldflags="-s -w"` - Stripped symbols for smaller size
- Build variable injection via `-X` flags

## Build Variables Integration

### Quick Start

Add one line to your `main()`:

```go
import "github.com/nzions/releases"

func main() {
    releases.Hijack(Version)  // Handles --buildinfo and --license

    // Your app logic
}
```

This automatically adds:
- `--buildinfo` - Shows version, git commit, build date, releaser URL
- `--license` - Shows full license text

### Available Variables

```go
var (
    GitCommit string  // Injected at build time
    BuildDate string  // Injected at build time
    URL       string  // Injected at build time
    License   string  // Injected at build time
)
```

### Available Functions

```go
releases.Hijack(version string)  // Intercepts --buildinfo and --license
releases.PrintMetadata()         // Prints git commit, build date, URL
releases.PrintLicense()          // Prints license text
```

### Example Implementation

```go
package main

import (
    "flag"
    "fmt"

    "github.com/nzions/releases"
)

const Version = "1.2.0"

func main() {
    releases.Hijack(Version)  // Auto-handles --buildinfo and --license

    version := flag.Bool("version", false, "show version")
    flag.Parse()

    if *version {
        fmt.Println(Version)
        return
    }

    // Your app logic
}
```

### Supported Flags

Your binary automatically supports:
- `--version` - Plain version (you handle this)
- `--buildinfo` - Version + build metadata (handled by Hijack)
- `--license` - License text (handled by Hijack)

### How It Works

The release script injects these variables at build time:

```bash
-X 'github.com/nzions/releases.GitCommit=abc123'
-X 'github.com/nzions/releases.BuildDate=2026-02-27T10:00:00Z'
-X 'github.com/nzions/releases.URL=https://github.com/nzions/releases'
-X 'github.com/nzions/releases.License=Copyright...'
```

## Project Structure

```
.
├── .binaries          # List of binaries to build
├── .gitignore         # Ignores .build-temp and temp files
├── DEVELOPER.md       # This file - technical documentation
├── LICENSE            # Proprietary license
├── README.md          # User-facing documentation
├── binaries/          # Built binaries (committed)
├── get.sh             # Installation script for end users
├── go.mod             # Go module definition
├── metadata.go        # Releases package with Hijack()
└── release.sh         # Build and release script
```

## Module Integration

In your project's `go.mod`, while developing locally:

```go
replace github.com/nzions/releases => ../releases
```

This allows you to use the local releases module during development.

## Supported Platforms

- linux/amd64
- linux/arm64
- darwin/amd64 (Intel Mac)
- darwin/arm64 (Apple Silicon)
- windows/amd64

## Binary Naming Convention

Built binaries follow this pattern:

```
binaries/<appname>/<appname>-<os>-<arch>-v<version>
binaries/<appname>/<appname>-<os>-<arch>-latest
```

Windows binaries include `.exe` extension.

The `-latest` files are copies that always point to the most recent version for easy downloading.

Examples:
- `binaries/certmania/certmania-linux-amd64-v1.2.0` (versioned)
- `binaries/certmania/certmania-linux-amd64-latest` (copy of latest)
- `binaries/certmania/certmania-windows-amd64-v1.2.0.exe` (Windows)
- `binaries/certmania/certmania-windows-amd64-latest.exe` (Windows latest)
- `binaries/simplecrypt/simplecrypt-darwin-arm64-v1.4.0` (versioned)
- `binaries/simplecrypt/simplecrypt-darwin-arm64-latest` (copy of latest)
