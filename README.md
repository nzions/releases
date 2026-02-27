# releases

Static Go binaries for private tools.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/nzions/releases/master/get.sh | bash
```

The installer will:
- Auto-detect your OS and architecture
- Verify SHA256 checksums for security
- Install to `~/go/bin` (if in your PATH) or `/usr/local/bin`
- Prompt you to select which tools to install

## Available Tools

- **buildr** - Build, containerize, and push Go binaries to OCI registries
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

## Verify Downloads

Each binary includes a SHA256 checksum file:

```bash
# Download binary and checksum
curl -LO https://github.com/nzions/releases/raw/master/binaries/certmania/certmania-linux-amd64-latest
curl -LO https://github.com/nzions/releases/raw/master/binaries/certmania/certmania-linux-amd64-latest.sum

# Verify checksum
shasum -a 256 -c certmania-linux-amd64-latest.sum
```

## Supported Platforms

- Linux (amd64, arm64)
- macOS (Intel, Apple Silicon)
- Windows (amd64)

---

**Built by [@nzions](https://github.com/nzions) and AI** (mostly AI)

**For Developers:** See [DEVELOPER.md](DEVELOPER.md) for build and integration documentation.
