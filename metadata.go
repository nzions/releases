package releases

import (
	"fmt"
	"os"
)

// Metadata variables injected at build time
var (
	GitCommit string
	BuildDate string
	URL       string
	License   string
)

func PrintMetadata() {
	fmt.Printf("Git Commit: %s\n", GitCommit)
	fmt.Printf("Build Date: %s\n", BuildDate)
	fmt.Printf("Releaser: %s\n", URL)
}

func PrintLicense() {
	fmt.Println(License)
}

// Hijack checks for --buildinfo and --license flags in os.Args
// If found, prints the information and exits. Otherwise returns.
func Hijack(version string) {
	for _, arg := range os.Args[1:] {
		if arg == "--buildinfo" {
			fmt.Printf("Version: %s\n", version)
			PrintMetadata()
			fmt.Println("For license, see --license")
			os.Exit(0)
		}
		if arg == "--license" {
			PrintLicense()
			os.Exit(0)
		}
	}
}
