# Build Variables Reference

The releases package provides metadata struct that's injected at build time.

## Import in Your CLI

```go
import "github.com/nzions/releases"
```

Your binary's version stays as a constant in your package:
```go
const Version = "1.2.0"
```

Release metadata is available as: `releases.BuildMetadata`

## Example Implementation

```go
package main

import (
	"flag"
	"fmt"

	"github.com/nzions/coreutils/certmania/ca"  // or your package
	"github.com/nzions/releases"
)

const Version = "1.2.0"  // Your app version

func main() {
	version := flag.Bool("version", false, "show version")
	help := flag.Bool("help", false, "show build details")
	license := flag.Bool("license", false, "show license")
	flag.Parse()

	if *version {
		fmt.Println(Version)
		return
	}

	if *help {
		fmt.Printf("Version: %s\n", Version)
		releases.BuildMetadata.PrintMetadata()
		fmt.Println("For license, see --license")
		return
	}

	if *license {
		releases.BuildMetadata.PrintLicense()
		return
	}

	// Your app logic
}
```

## Metadata Structure

```go
type Metadata struct {
	GitCommit string  // Short commit hash from source repo
	BuildDate string  // RFC3339 UTC timestamp
	URL       string  // URL to releases repository
	License   string  // Full license text
}

// Methods available:
// BuildMetadata.PrintMetadata()  // Prints git commit, build date, URL
// BuildMetadata.PrintLicense()   // Prints license text
```
