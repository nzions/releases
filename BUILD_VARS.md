# Build Variables Reference

The release script injects these variables into binaries at build time:

```go
package main

var (
    Version     string // e.g., "v1.2.0"
    GitCommit   string // e.g., "abc123d"
    BuildDate   string // e.g., "2026-02-27T10:30:00Z"
    ReleaserURL string // "https://github.com/nzions/releases"
    License     string // License notice
)
```

## Usage Example

```go
package main

import (
    "flag"
    "fmt"
    "os"
)

var (
    // Injected at build time
    Version     = "dev"
    GitCommit   = "unknown"
    BuildDate   = "unknown"
    ReleaserURL = ""
    License     = ""
)

func main() {
    showVersion := flag.Bool("version", false, "show version")
    showLicense := flag.Bool("license", false, "show license")
    flag.Parse()

    if *showVersion {
        fmt.Printf("version %s (commit: %s, built: %s)\n", Version, GitCommit, BuildDate)
        if ReleaserURL != "" {
            fmt.Printf("releases: %s\n", ReleaserURL)
        }
        os.Exit(0)
    }

    if *showLicense {
        fmt.Println(License)
        os.Exit(0)
    }

    // Your main program logic
}
```

## Variables Injected

- `main.Version` - Version from binary's `--version` output
- `main.GitCommit` - Short commit hash (7 chars) from source repo
- `main.BuildDate` - RFC3339 UTC timestamp
- `main.ReleaserURL` - URL to releases repository
- `main.License` - Copyright and license notice
