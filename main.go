package main

import (
	"fmt"
	"os"

	"github.com/sup3r7-fabio/gh-pwsh-skills/cmd"
)

// Version information, set by goreleaser
var (
	version = "dev"
	commit  = "none"
	date    = "unknown"
	builtBy = "unknown"
)

func main() {
	// Set version info for the CLI
	cmd.SetVersionInfo(version, commit, date, builtBy)
	
	if err := cmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
