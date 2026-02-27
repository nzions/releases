# releases

Static Go binaries for private tools.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/nzions/releases/master/get.sh | bash
```

The installer will:
- Auto-detect your OS and architecture
- Install to `~/go/bin` (if in your PATH) or `/usr/local/bin`
- Prompt you to select which tools to install

## Available Tools

- **certmania** - Certificate management utility
- **simplecrypt** - Encrypted credential storage

## Usage

All tools support these standard flags:

```bash
# Show version
<tool> --version

# Show build metadata (version, git commit, build date)
<tool> --buildinfo

# Show license
<tool> --license

# Tool-specific help
<tool> --help
```

## Supported Platforms

- Linux (amd64, arm64)
- macOS (Intel, Apple Silicon)
- Windows (amd64)

---

**For Developers:** See [DEVELOPER.md](DEVELOPER.md) for build and integration documentation.
