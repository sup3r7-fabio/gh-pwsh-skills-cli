package cmd

import (
"fmt"
"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
Use:   "pwsh-skills",
Short: "Interactive PowerShell GitHub Skills course assistant",
Long: `A GitHub CLI extension that enhances your PowerShell GitHub Skills learning experience.

Available Commands:
  status     Show current progress across all PowerShell courses
  hint       Get contextual hints for the current step  
  validate   Validate your PowerShell solution locally
  next       Navigate to the next PowerShell course
  back       Navigate back to the previous PowerShell course

Use "gh pwsh-skills [command] --help" for more information about a command.`,
Run: func(cmd *cobra.Command, args []string) {
fmt.Println("🚀 Welcome to PowerShell GitHub Skills!")
fmt.Println()
fmt.Println("📚 Available Commands:")
fmt.Println("  status     📊 Show your progress across all courses")
fmt.Println("  hint       💡 Get contextual hints for your current step")
fmt.Println("  validate   🧪 Test your PowerShell code locally")
fmt.Println("  next       ⏭️  Move to the next course")
fmt.Println("  back       ⏮️  Go back to the previous course")
fmt.Println()
fmt.Println("💡 Start with 'gh pwsh-skills status' to see your current progress!")
},
}

func Execute() error {
return rootCmd.Execute()
}
