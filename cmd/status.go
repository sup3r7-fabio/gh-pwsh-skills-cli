package cmd

import (
"encoding/json"
"fmt"
"os"
"path/filepath"

"github.com/cli/go-gh"
"github.com/spf13/cobra"
)

// CourseProgress is now defined in course_utils.go as CourseInfo

var statusCmd = &cobra.Command{
Use:   "status",
Short: "Show current progress across all PowerShell courses",
Long:  `Display your current progress in all PowerShell GitHub Skills courses`,
Run: func(cmd *cobra.Command, args []string) {
showStatus()
},
}

func showStatus() {
fmt.Println("📍 PowerShell GitHub Skills - Progress Status")
fmt.Println("=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=")

// Check if we''re in a git repository
if !isGitRepo() {
fmt.Println("❌ Not in a git repository. Please run from your PowerShell Skills course directory.")
return
}

// Get repository information
repoInfo, err := getRepoInfo()
if err != nil {
fmt.Printf("❌ Error getting repository info: %v\n", err)
return
}

fmt.Printf("📂 Repository: %s\n", repoInfo)

// Detect courses and progress
courses := DetectAvailableCourses()
if len(courses) == 0 {
fmt.Println("❌ No PowerShell Skills courses detected in this repository.")
return
}

fmt.Println("\n🎯 Course Progress:")
for _, course := range courses {
displayCourseProgress(course)
}

// Overall progress
completed, total, percentage := GetCourseProgressSummary()
fmt.Printf("\n🏆 Overall Progress: %d/%d courses completed (%.1f%%)\n", 
completed, total, percentage)
}

func isGitRepo() bool {
_, err := os.Stat(".git")
return err == nil
}

func getRepoInfo() (string, error) {
args := []string{"repo", "view", "--json", "nameWithOwner"}
stdOut, _, err := gh.Exec(args...)
if err != nil {
return "", err
}

var repo struct {
NameWithOwner string `json:"nameWithOwner"`
}

if err := json.Unmarshal(stdOut.Bytes(), &repo); err != nil {
return "", err
}

return repo.NameWithOwner, nil
}

// Course utility functions moved to course_utils.go

func displayCourseProgress(course CourseInfo) {
status := "🔄"
if course.Completed {
status = "✅"
}

progressBar := ""
for i := 1; i <= course.TotalSteps; i++ {
if i <= course.CurrentStep {
progressBar += "█"
} else {
progressBar += "░"
}
}

fmt.Printf("  %s %s\n", status, course.Name)
fmt.Printf("     Progress: [%s] %d/%d steps\n", progressBar, course.CurrentStep, course.TotalSteps)

if !course.Completed {
estimatedTime := (course.TotalSteps - course.CurrentStep) * 10
fmt.Printf("     ⏱️  Estimated time remaining: %d minutes\n", estimatedTime)
}
fmt.Println()
}

func init() {
rootCmd.AddCommand(statusCmd)
}
