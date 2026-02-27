# Build Variables Reference

The `releases` package provides build metadata injection for Go binaries.

## Quick Start

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

## Available Variables

```go
var (
    GitCommit string  // Injected at build time
    BuildDate string  // Injected at build time
    URL       string  // Injected at build time
    License   string  // Injected at build time
)
```

## Available Functions

```go
releases.Hijack(version string)  // Intercepts --buildinfo and --license
releases.PrintMetadata()         // Prints git commit, build date, URL
releases.PrintLicense()          // Prints license text
```

## Example Implementation

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

## Supported Flags

Your binary automatically supports:
- `--version` - Plain version (you handle this)
- `--buildinfo` - Version + build metadata (handled by Hijack)
- `--license` - License text (handled by Hijack)

## How It Works

The release script injects these variables at build time:

```bash
-X 'github.com/nzions/releases.GitCommit=abc123'
-X 'github.com/nzions/releases.BuildDate=2026-02-27T10:00:00Z'
-X 'github.com/nzions/releases.URL=https://github.com/nzions/releases'
-X 'github.com/nzions/releases.License=Copyright...'
```
