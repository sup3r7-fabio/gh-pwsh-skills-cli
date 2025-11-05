package cmd

import (
"encoding/json"
"fmt"
"os"
"path/filepath"

"github.com/cli/go-gh"
"github.com/spf13/cobra"
)

type CourseProgress struct {
Name        string `json:"name"`
CurrentStep int    `json:"current_step"`
TotalSteps  int    `json:"total_steps"`
Completed   bool   `json:"completed"`
}

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
courses := detectCourses()
if len(courses) == 0 {
fmt.Println("❌ No PowerShell Skills courses detected in this repository.")
return
}

fmt.Println("\n🎯 Course Progress:")
for _, course := range courses {
displayCourseProgress(course)
}

// Overall progress
completed := 0
total := len(courses)
for _, course := range courses {
if course.Completed {
completed++
}
}

fmt.Printf("\n🏆 Overall Progress: %d/%d courses completed (%.1f%%)\n", 
completed, total, float64(completed)/float64(total)*100)
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

func detectCourses() []CourseProgress {
var courses []CourseProgress

// Course 1 (root directory)
if hasWorkflowFiles(".") {
courses = append(courses, CourseProgress{
Name:        "Course 1: PowerShell Fundamentals",
CurrentStep: getCurrentStep("."),
TotalSteps:  5,
Completed:   isCompleted("."),
})
}

// Course 2
if hasWorkflowFiles("course-2-pipelines-filtering") {
courses = append(courses, CourseProgress{
Name:        "Course 2: Pipelines & Filtering",
CurrentStep: getCurrentStep("course-2-pipelines-filtering"),
TotalSteps:  5,
Completed:   isCompleted("course-2-pipelines-filtering"),
})
}

// Course 3
if hasWorkflowFiles("course-3-functions-modules") {
courses = append(courses, CourseProgress{
Name:        "Course 3: Functions & Modules",
CurrentStep: getCurrentStep("course-3-functions-modules"),
TotalSteps:  5,
Completed:   isCompleted("course-3-functions-modules"),
})
}

// Course 4
if hasWorkflowFiles("course-4-automation-devops") {
courses = append(courses, CourseProgress{
Name:        "Course 4: Automation & DevOps",
CurrentStep: getCurrentStep("course-4-automation-devops"),
TotalSteps:  5,
Completed:   isCompleted("course-4-automation-devops"),
})
}

return courses
}

func hasWorkflowFiles(dir string) bool {
workflowDir := filepath.Join(dir, ".github", "workflows")
_, err := os.Stat(workflowDir)
return err == nil
}

func getCurrentStep(dir string) int {
// This is a simplified implementation
// In a real scenario, you''d parse git history or workflow status
return 1
}

func isCompleted(dir string) bool {
// Simplified - would check git history for completion
return false
}

func displayCourseProgress(course CourseProgress) {
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
