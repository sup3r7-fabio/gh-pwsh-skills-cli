package main

import (
"fmt"
"os"

"github.com/sup3r7-fabio/gh-pwsh-skills/cmd"
)

func main() {
if err := cmd.Execute(); err != nil {
fmt.Fprintf(os.Stderr, "Error: %v\n", err)
os.Exit(1)
}
}
