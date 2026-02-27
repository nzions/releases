# releases

Build and release binaries from source repos using `go build`.

## Install Binaries

```bash
curl -sSL https://raw.githubusercontent.com/nzions/releases/master/get.sh | bash
```

This auto-detects your OS/architecture and installs the latest versions to `~/bin`.

## Build New Releases

```bash
./release.sh
```

Builds all binaries listed in `.binaries` for all platforms, creates git tags, commits, and pushes.

## Configuration

Edit `.binaries` (one per line, format: `path` or `path:appname`):

```
~/code/coreutils/certmania/cli:certmania
~/code/coreutils/simplecrypt/cli:simplecrypt
```

If no appname specified, uses the directory name.

## Requirements

- Go installed
- Each binary supports `go run . --version`

## Output

Binaries go to `binaries/<name>/<os>-<arch>-v<version>`

Platforms built: linux/amd64, linux/arm64, darwin/amd64, darwin/arm64, windows/amd64
