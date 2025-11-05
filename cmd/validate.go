package cmd

import (
"fmt"
"os"
"os/exec"
"path/filepath"
"strings"

"github.com/spf13/cobra"
)

var validateCmd = &cobra.Command{
Use:   "validate",
Short: "Validate your PowerShell solution locally",
Long:  `Test your PowerShell code locally before committing to ensure it works correctly`,
Run: func(cmd *cobra.Command, args []string) {
runValidation()
},
}

func runValidation() {
fmt.Println("🧪 PowerShell Solution Validation")
fmt.Println("=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=")

// Check if PowerShell is available
if !isPowerShellAvailable() {
fmt.Println("❌ PowerShell not found. Please install PowerShell 7+ for cross-platform compatibility.")
fmt.Println("   Visit: https://github.com/PowerShell/PowerShell#get-powershell")
return
}

fmt.Println("✅ PowerShell detected")

// Find PowerShell files to validate
psFiles := findPowerShellFiles()
if len(psFiles) == 0 {
fmt.Println("❌ No PowerShell files found in current directory")
fmt.Println("   Make sure you have created .ps1 files for your solution")
return
}

fmt.Printf("🔍 Found %d PowerShell file(s) to validate:\n", len(psFiles))
for _, file := range psFiles {
fmt.Printf("   • %s\n", file)
}
fmt.Println()

// Validate each file
allValid := true
for _, file := range psFiles {
if !validatePowerShellFile(file) {
allValid = false
}
}

fmt.Println()
if allValid {
fmt.Println("🎉 All validations passed!")
fmt.Println("🚀 Your solution is ready to commit and push!")
fmt.Println()
fmt.Println("Next steps:")
fmt.Println("1. git add .")
fmt.Println("2. git commit -m \"Complete step X\"")
fmt.Println("3. git push")
fmt.Println()
fmt.Println("💡 Use ''gh pwsh-skills status'' to check your progress")
} else {
fmt.Println("❌ Some validations failed. Please fix the issues and try again.")
}
}

func isPowerShellAvailable() bool {
// Check for pwsh (PowerShell 7+)
_, err := exec.LookPath("pwsh")
if err == nil {
return true
}

// Check for powershell (Windows PowerShell)
_, err = exec.LookPath("powershell")
return err == nil
}

func findPowerShellFiles() []string {
var files []string

// Look for .ps1 files in current directory
filepath.Walk(".", func(path string, info os.FileInfo, err error) error {
if err != nil {
return nil
}

// Skip hidden directories and files
if strings.HasPrefix(info.Name(), ".") {
if info.IsDir() {
return filepath.SkipDir
}
return nil
}

// Skip certain directories
skipDirs := []string{"node_modules", "bin", "obj", ".git"}
for _, skipDir := range skipDirs {
if strings.Contains(path, skipDir) {
return nil
}
}

if strings.HasSuffix(strings.ToLower(info.Name()), ".ps1") {
files = append(files, path)
}

return nil
})

return files
}

func validatePowerShellFile(filename string) bool {
fmt.Printf("🔍 Validating: %s\n", filename)

// 1. Syntax validation
if !validateSyntax(filename) {
return false
}

// 2. Cross-platform compatibility check
if !checkCrossPlatformCompatibility(filename) {
return false
}

// 3. Best practices check
checkBestPractices(filename)

fmt.Printf("✅ %s - All checks passed\n", filename)
return true
}

func validateSyntax(filename string) bool {
// Use PowerShell to parse the script and check for syntax errors
var cmd *exec.Cmd

// Try pwsh first (PowerShell 7+)
if _, err := exec.LookPath("pwsh"); err == nil {
cmd = exec.Command("pwsh", "-NoProfile", "-Command", 
fmt.Sprintf("try { $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content ''%s'' -Raw), [ref]$null); Write-Host ''OK'' } catch { Write-Error $_.Exception.Message; exit 1 }", filename))
} else {
cmd = exec.Command("powershell", "-NoProfile", "-Command", 
fmt.Sprintf("try { $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content ''%s'' -Raw), [ref]$null); Write-Host ''OK'' } catch { Write-Error $_.Exception.Message; exit 1 }", filename))
}

output, err := cmd.CombinedOutput()
if err != nil {
fmt.Printf("  ❌ Syntax Error: %s\n", strings.TrimSpace(string(output)))
return false
}

fmt.Printf("  ✅ Syntax: Valid\n")
return true
}

func checkCrossPlatformCompatibility(filename string) bool {
// Read file content
content, err := os.ReadFile(filename)
if err != nil {
fmt.Printf("  ❌ Could not read file: %v\n", err)
return false
}

fileContent := string(content)
issues := []string{}

// Check for Windows-specific cmdlets that might not work on Linux/macOS
windowsOnlyCmdlets := []string{
"Get-WmiObject",
"Get-Service", // Note: Available on Linux but with limited functionality
"New-Service",
"Set-Service",
"Get-EventLog",
"Get-WindowsFeature",
}

for _, cmdlet := range windowsOnlyCmdlets {
if strings.Contains(fileContent, cmdlet) {
issues = append(issues, fmt.Sprintf("''%s'' may not work on all platforms", cmdlet))
}
}

// Check for hardcoded Windows paths
if strings.Contains(fileContent, "C:\\") || strings.Contains(fileContent, "\\\\") {
issues = append(issues, "Hardcoded Windows paths detected")
}

if len(issues) > 0 {
fmt.Printf("  ⚠️  Cross-platform compatibility warnings:\n")
for _, issue := range issues {
fmt.Printf("     • %s\n", issue)
}
} else {
fmt.Printf("  ✅ Cross-platform: Compatible\n")
}

return true // Don''t fail on warnings, just inform
}

func checkBestPractices(filename string) {
content, err := os.ReadFile(filename)
if err != nil {
return
}

fileContent := string(content)
suggestions := []string{}

// Check for common best practices
if !strings.Contains(fileContent, "[CmdletBinding()]") && strings.Contains(fileContent, "function") {
suggestions = append(suggestions, "Consider adding [CmdletBinding()] to functions")
}

if strings.Contains(fileContent, "Write-Host") {
suggestions = append(suggestions, "Consider using Write-Output instead of Write-Host for better pipeline support")
}

if !strings.Contains(fileContent, "param(") && strings.Contains(fileContent, "function") {
suggestions = append(suggestions, "Consider adding parameter blocks to functions")
}

if len(suggestions) > 0 {
fmt.Printf("  💡 Best practice suggestions:\n")
for _, suggestion := range suggestions {
fmt.Printf("     • %s\n", suggestion)
}
}
}

func init() {
rootCmd.AddCommand(validateCmd)
}
