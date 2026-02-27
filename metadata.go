package releases

import "fmt"

type Metadata struct {
	GitCommit string
	BuildDate string
	URL       string
	License   string
}

// These are set by -X flags at build time
var (
	gitCommit string
	buildDate string
	url       string
	license   string
)

var BuildMetadata Metadata

func init() {
	BuildMetadata = Metadata{
		GitCommit: gitCommit,
		BuildDate: buildDate,
		URL:       url,
		License:   license,
	}
}

func (m Metadata) PrintMetadata() {
	fmt.Printf("Git Commit: %s\n", m.GitCommit)
	fmt.Printf("Build Date: %s\n", m.BuildDate)
	fmt.Printf("Releaser: %s\n", m.URL)
}

func (m Metadata) PrintLicense() {
	fmt.Println(m.License)
}
