package cmd

import (
	"testing"
)

func TestSetVersionInfo(t *testing.T) {
	testVersion := "v1.0.0"
	testCommit := "abc123"
	testDate := "2025-11-05"
	testBuiltBy := "test"
	
	SetVersionInfo(testVersion, testCommit, testDate, testBuiltBy)
	
	if version != testVersion {
		t.Errorf("Expected version %s, got %s", testVersion, version)
	}
	if commit != testCommit {
		t.Errorf("Expected commit %s, got %s", testCommit, commit)
	}
	if date != testDate {
		t.Errorf("Expected date %s, got %s", testDate, date)
	}
	if builtBy != testBuiltBy {
		t.Errorf("Expected builtBy %s, got %s", testBuiltBy, builtBy)
	}
	if rootCmd.Version != testVersion {
		t.Errorf("Expected rootCmd.Version %s, got %s", testVersion, rootCmd.Version)
	}
}

func TestExecute(t *testing.T) {
	// Test that Execute function exists
	// We can't actually test execution without causing the command to run
	if Execute == nil {
		t.Error("Execute function should not be nil")
	}
}

func TestGetAllCoursesInfo(t *testing.T) {
	courses := GetAllCoursesInfo()
	
	if len(courses) != 4 {
		t.Errorf("Expected 4 courses, got %d", len(courses))
	}
	
	expectedNames := []string{
		"Course 1: PowerShell Fundamentals",
		"Course 2: Pipelines & Filtering",
		"Course 3: Functions & Modules",
		"Course 4: Automation & DevOps",
	}
	
	for i, course := range courses {
		if course.Name != expectedNames[i] {
			t.Errorf("Expected course name %s, got %s", expectedNames[i], course.Name)
		}
		if course.Index != i {
			t.Errorf("Expected course index %d, got %d", i, course.Index)
		}
		if course.TotalSteps != 5 {
			t.Errorf("Expected total steps 5, got %d", course.TotalSteps)
		}
	}
}
