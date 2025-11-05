package cmd

import (
"fmt"
"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
Use:   "pwsh-skills",
Short: "Interactive PowerShell GitHub Skills course assistant",
Run: func(cmd *cobra.Command, args []string) {
fmt.Println("🚀 Welcome to PowerShell GitHub Skills!")
},
}

func Execute() error {
return rootCmd.Execute()
}
