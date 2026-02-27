package releases

import "fmt"

type Metadata struct {
	GitCommit string
	BuildDate string
	URL       string
	License   string
}

var BuildMetadata Metadata

func (m Metadata) PrintMetadata() {
	fmt.Printf("Git Commit: %s\n", m.GitCommit)
	fmt.Printf("Build Date: %s\n", m.BuildDate)
	fmt.Printf("Releaser: %s\n", m.URL)
}

func (m Metadata) PrintLicense() {
	fmt.Println(m.License)
}
