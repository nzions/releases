# releases

Build and release binaries from source repos using `go build`.

## Quick Start

```bash
./release.sh
```

Builds all binaries listed in `.binaries` for all platforms, creates git tags, commits, and pushes.

## Configuration

Edit `.binaries` (one path per line):

```
~/code/coreutils/certmania/cli
~/code/coreutils/simplecrypt/cli
```

## Requirements

- Go installed
- Each binary supports `go run . --version`

## Output

Binaries go to `binaries/<name>/<os>-<arch>-v<version>`

Platforms built: linux/amd64, linux/arm64, darwin/amd64, darwin/arm64, windows/amd64
