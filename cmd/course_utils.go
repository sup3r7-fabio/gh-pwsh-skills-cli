package cmd

import (
	"os"
	"path/filepath"
)

// Course represents a PowerShell GitHub Skills course
type CourseInfo struct {
	Name        string `json:"name"`
	Directory   string `json:"directory"`
	Index       int    `json:"index"`
	CurrentStep int    `json:"current_step"`
	TotalSteps  int    `json:"total_steps"`
	Completed   bool   `json:"completed"`
}

// GetAllCoursesInfo returns information about all available courses
func GetAllCoursesInfo() []CourseInfo {
	courseNames := []string{
		"Course 1: PowerShell Fundamentals",
		"Course 2: Pipelines & Filtering", 
		"Course 3: Functions & Modules",
		"Course 4: Automation & DevOps",
	}
	
	courseDirectories := []string{
		".",
		"course-2-pipelines-filtering",
		"course-3-functions-modules", 
		"course-4-automation-devops",
	}
	
	courses := make([]CourseInfo, len(courseNames))
	
	for i := range courseNames {
		courses[i] = CourseInfo{
			Name:        courseNames[i],
			Directory:   courseDirectories[i],
			Index:       i,
			CurrentStep: getCurrentStep(courseDirectories[i]),
			TotalSteps:  5,
			Completed:   isCompleted(courseDirectories[i]),
		}
	}
	
	return courses
}

// DetectAvailableCourses returns only courses that are available/detected
func DetectAvailableCourses() []CourseInfo {
	allCourses := GetAllCoursesInfo()
	var availableCourses []CourseInfo
	
	for _, course := range allCourses {
		if hasWorkflowFiles(course.Directory) {
			availableCourses = append(availableCourses, course)
		}
	}
	
	return availableCourses
}

// DetectCurrentCourseInfo returns the current course information
func DetectCurrentCourseInfo() *CourseInfo {
	courses := GetAllCoursesInfo()
	
	// Check course directories in reverse order (most specific first)
	for i := len(courses) - 1; i >= 0; i-- {
		if hasWorkflowFiles(courses[i].Directory) && isInCourseDirectory(courses[i].Directory) {
			return &courses[i]
		}
	}
	
	return nil
}

// GetNextCourseInfo returns the next available course
func GetNextCourseInfo(currentCourse *CourseInfo) *CourseInfo {
	if currentCourse == nil {
		return nil
	}
	
	courses := GetAllCoursesInfo()
	
	// Find next available course
	for i := currentCourse.Index + 1; i < len(courses); i++ {
		// Check if course exists or will be available
		if hasWorkflowFiles(courses[i].Directory) || courses[i].Directory != "." {
			return &courses[i]
		}
	}
	
	return nil
}

// GetPreviousCourseInfo returns the previous available course
func GetPreviousCourseInfo(currentCourse *CourseInfo) *CourseInfo {
	if currentCourse == nil {
		return nil
	}
	
	courses := GetAllCoursesInfo()
	
	// Find previous available course
	for i := currentCourse.Index - 1; i >= 0; i-- {
		if hasWorkflowFiles(courses[i].Directory) || courses[i].Directory == "." {
			return &courses[i]
		}
	}
	
	return nil
}

// NavigateToCourseDirectory changes to the specified course directory
func NavigateToCourseDirectory(course *CourseInfo) error {
	if course.Directory == "." {
		// Already in root directory
		return nil
	}
	
	// Check if directory exists
	if _, err := os.Stat(course.Directory); os.IsNotExist(err) {
		return err
	}
	
	// Change to course directory
	return os.Chdir(course.Directory)
}

// isInCourseDirectory checks if we're currently in the specified course directory
func isInCourseDirectory(dir string) bool {
	if dir == "." {
		return true // Always true for root directory
	}
	
	// Check if we're currently in the specified directory
	pwd, err := os.Getwd()
	if err != nil {
		return false
	}
	
	// Check if current directory ends with the course directory name
	return filepath.Base(pwd) == filepath.Base(dir) || 
		   hasWorkflowFiles(dir)
}

// GetCourseProgressSummary returns overall progress statistics
func GetCourseProgressSummary() (completed int, total int, percentage float64) {
	courses := DetectAvailableCourses()
	total = len(courses)
	completed = 0
	
	for _, course := range courses {
		if course.Completed {
			completed++
		}
	}
	
	if total > 0 {
		percentage = float64(completed) / float64(total) * 100
	}
	
	return completed, total, percentage
}

// hasWorkflowFiles checks if a directory contains GitHub workflow files
func hasWorkflowFiles(dir string) bool {
	workflowDir := filepath.Join(dir, ".github", "workflows")
	_, err := os.Stat(workflowDir)
	return err == nil
}

// getCurrentStep returns the current step for a course (simplified implementation)
func getCurrentStep(dir string) int {
	// This is a simplified implementation
	// In a real scenario, you'd parse git history or workflow status
	return 1
}

// isCompleted checks if a course is completed (simplified implementation)
func isCompleted(dir string) bool {
	// Simplified - would check git history for completion
	return false
}

// isGitRepo checks if the current directory is a git repository
func isGitRepo() bool {
	_, err := os.Stat(".git")
	return err == nil
}
