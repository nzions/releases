# releases

Static Go binaries for private tools.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/nzions/releases/master/get.sh | bash
```

Auto-detects your OS/architecture and installs to `~/go/bin` or `/usr/local/bin`.

## Available Tools

- **certmania** - Certificate management utility
- **simplecrypt** - Encrypted credential storage

## Features

All binaries include:
- Static compilation (no external dependencies)
- Stripped for minimal size
- Build metadata injection (commit, date, license)
- Consistent `--version`, `--buildinfo`, `--license` flags

---

<details>
<summary>For Maintainers: Release Process</summary>

### Building Releases

```bash
bash release.sh
```

This script:
1. Reads binary paths from `.binaries`
2. Extracts version from `--version` output
3. Builds for 5 platforms (linux/arm64, linux/amd64, darwin/arm64, darwin/amd64, windows/amd64)
4. Injects build metadata
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

### Integrating Build Metadata

Add to your CLI's `main()`:

```go
import "github.com/nzions/releases"

func main() {
    releases.Hijack(Version)  // Handles --buildinfo and --license
    // Your app logic
}
```

See [BUILD_VARS.md](BUILD_VARS.md) for full documentation.

### Project Structure

```
.
├── .binaries          # List of binaries to build
├── .gitignore         # Ignores .build-temp
├── BUILD_VARS.md      # Build variable documentation
├── LICENSE            # Proprietary license
├── README.md          # This file
├── binaries/          # Built binaries (committed)
├── get.sh             # Installation script
├── go.mod             # Go module definition
├── metadata.go        # Releases package with Hijack()
└── release.sh         # Build and release script
```

</details>
