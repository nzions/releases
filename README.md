# releases

Static Go binaries for various tools.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/nzions/releases/master/get.sh | bash
```

Auto-detects your OS/architecture and installs to `~/go/bin` or `/usr/local/bin`.

## Tools

- **certmania** - Certificate management utility
- **simplecrypt** - Simple encryption/decryption tool

---

<details>
<summary>For maintainers: Building releases</summary>

### Build New Releases

```bash
bash release.sh
```

Builds all binaries from `.binaries`, creates git tags, commits, and pushes.

### Configuration

Edit `.binaries` (format: `path:appname`):

```
~/code/coreutils/certmania/cli:certmania
~/code/coreutils/simplecrypt/cli:simplecrypt
```

### Platforms

linux/amd64, linux/arm64, darwin/amd64, darwin/arm64, windows/amd64

Binaries are static (CGO_ENABLED=0, -tags netgo) and stripped (-ldflags="-s -w").

</details>
