package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var backCmd = &cobra.Command{
	Use:   "back",
	Short: "Navigate back to the previous PowerShell course",
	Long:  `Go back to the previous PowerShell GitHub Skills course in sequence`,
	Run: func(cmd *cobra.Command, args []string) {
		navigateBack()
	},
}

func navigateBack() {
	fmt.Println("⏮️  PowerShell GitHub Skills - Previous Course")
	fmt.Println("=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=")

	// Check if we're in a git repository
	if !isGitRepo() {
		fmt.Println("❌ Not in a git repository. Please run from your PowerShell Skills course directory.")
		return
	}

	// Detect current course and find previous
	currentCourse := DetectCurrentCourseInfo()
	if currentCourse == nil {
		fmt.Println("❌ Could not detect current course. Please ensure you're in a PowerShell Skills course directory.")
		return
	}

	previousCourse := GetPreviousCourseInfo(currentCourse)
	if previousCourse == nil {
		fmt.Println("🎯 You're already at the first course!")
		fmt.Println("💡 This is where your PowerShell journey begins. Move forward with 'gh pwsh-skills next' when ready!")
		return
	}

	// Navigate to previous course
	fmt.Printf("📍 Current: %s\n", currentCourse.Name)
	fmt.Printf("⏮️  Previous: %s\n\n", previousCourse.Name)

	if err := NavigateToCourseDirectory(previousCourse); err != nil {
		fmt.Printf("❌ Error changing to directory '%s': %v\n", previousCourse.Directory, err)
		fmt.Printf("💡 You may need to manually switch to the directory: %s\n", previousCourse.Directory)
		return
	}

	fmt.Printf("✅ Successfully navigated back to: %s\n", previousCourse.Name)
	fmt.Printf("📂 Directory: %s\n\n", previousCourse.Directory)
	
	// Show what to do next
	fmt.Println("🔄 Back to previous course!")
	fmt.Println("You can:")
	fmt.Println("1. Review the course content")
	fmt.Println("2. Re-read the README.md")
	fmt.Println("3. Use 'gh pwsh-skills status' to check progress")
	fmt.Println("4. Use 'gh pwsh-skills next' to move forward again")
}

func init() {
	rootCmd.AddCommand(backCmd)
}
