package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

var nextCmd = &cobra.Command{
	Use:   "next",
	Short: "Navigate to the next PowerShell course",
	Long:  `Move to the next available PowerShell GitHub Skills course in sequence`,
	Run: func(cmd *cobra.Command, args []string) {
		navigateToNext()
	},
}

func navigateToNext() {
	fmt.Println("⏭️  PowerShell GitHub Skills - Next Course")
	fmt.Println("=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=")

	// Check if we're in a git repository
	if !isGitRepo() {
		fmt.Println("❌ Not in a git repository. Please run from your PowerShell Skills course directory.")
		return
	}

	// Detect current course and find next
	currentCourse := DetectCurrentCourseInfo()
	if currentCourse == nil {
		fmt.Println("❌ Could not detect current course. Please ensure you're in a PowerShell Skills course directory.")
		return
	}

	nextCourse := GetNextCourseInfo(currentCourse)
	if nextCourse == nil {
		fmt.Println("🎉 Congratulations! You've completed all available PowerShell courses!")
		fmt.Println("🏆 You're at the final course. Great job on your PowerShell journey!")
		return
	}

	// Navigate to next course
	fmt.Printf("📍 Current: %s\n", currentCourse.Name)
	fmt.Printf("⏭️  Next: %s\n\n", nextCourse.Name)

	if err := NavigateToCourseDirectory(nextCourse); err != nil {
		if os.IsNotExist(err) {
			fmt.Printf("⚠️  Course directory '%s' does not exist yet.\n", nextCourse.Directory)
			fmt.Println("💡 This course may be available later in your learning journey.")
		} else {
			fmt.Printf("❌ Error changing to directory '%s': %v\n", nextCourse.Directory, err)
			fmt.Printf("💡 You may need to manually switch to the directory: %s\n", nextCourse.Directory)
		}
		return
	}

	fmt.Printf("✅ Successfully navigated to: %s\n", nextCourse.Name)
	fmt.Printf("📂 Directory: %s\n\n", nextCourse.Directory)
	
	// Show what to do next
	fmt.Println("🚀 Ready to start!")
	fmt.Println("Next steps:")
	fmt.Println("1. Read the course README.md")
	fmt.Println("2. Follow the step-by-step instructions")
	fmt.Println("3. Use 'gh pwsh-skills hint' for contextual help")
	fmt.Println("4. Use 'gh pwsh-skills validate' to test your solutions")
}

// Navigation utilities are now in course_utils.go

func init() {
	rootCmd.AddCommand(nextCmd)
}
