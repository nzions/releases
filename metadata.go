package releases

import "fmt"

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
