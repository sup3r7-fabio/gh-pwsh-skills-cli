package cmd

import (
"fmt"
"math/rand"
"time"

"github.com/spf13/cobra"
)

var hintCmd = &cobra.Command{
Use:   "hint",
Short: "Get contextual hints for the current step",
Long:  `Provides helpful hints and guidance for your current PowerShell learning step`,
Run: func(cmd *cobra.Command, args []string) {
showHint()
},
}

type Hint struct {
Title       string
Description string
Example     string
Reference   string
}

var powerShellHints = map[string][]Hint{
"fundamentals": {
{
Title:       "Variables and Assignment",
Description: "In PowerShell, variables start with $ and are dynamically typed",
Example:     "$name = \"PowerShell\"; $number = 42",
Reference:   "https://docs.microsoft.com/powershell/scripting/lang-spec/chapter-05",
},
{
Title:       "Conditional Logic",
Description: "Use if/elseif/else for conditional execution",
Example:     "if ($condition) { Write-Host \"True\" } else { Write-Host \"False\" }",
Reference:   "https://docs.microsoft.com/powershell/scripting/lang-spec/chapter-08",
},
},
"pipelines": {
{
Title:       "Pipeline Basics",
Description: "PowerShell pipeline passes objects, not text. Use | to chain commands",
Example:     "Get-Process | Where-Object { $_.CPU -gt 100 } | Select-Object Name, CPU",
Reference:   "https://docs.microsoft.com/powershell/scripting/learn/understanding-the-powershell-pipeline",
},
{
Title:       "Filtering Objects",
Description: "Where-Object filters objects based on conditions",
Example:     "Get-Service | Where-Object Status -eq \"Running\"",
Reference:   "https://docs.microsoft.com/powershell/module/microsoft.powershell.core/where-object",
},
},
"functions": {
{
Title:       "Function Definition",
Description: "Define reusable functions with param blocks and proper documentation",
Example:     "function Get-SystemInfo { [CmdletBinding()] param() Get-ComputerInfo }",
Reference:   "https://docs.microsoft.com/powershell/scripting/learn/ps101/09-functions",
},
{
Title:       "Parameter Validation",
Description: "Use parameter attributes for input validation",
Example:     "[Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string]$Name",
Reference:   "https://docs.microsoft.com/powershell/scripting/developer/cmdlet/validating-parameter-input",
},
},
"automation": {
{
Title:       "Error Handling",
Description: "Use try/catch blocks for robust error handling",
Example:     "try { Get-Item $path } catch { Write-Error \"File not found: $path\" }",
Reference:   "https://docs.microsoft.com/powershell/scripting/learn/deep-dives/everything-about-exceptions",
},
{
Title:       "Classes and Objects",
Description: "Define custom classes for complex automation scenarios",
Example:     "class Server { [string]$Name [string]$Environment }",
Reference:   "https://docs.microsoft.com/powershell/scripting/lang-spec/chapter-05#5.14-classes",
},
},
}

func showHint() {
fmt.Println("💡 PowerShell GitHub Skills - Contextual Hint")
fmt.Println("=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=" + "=")

// Detect current course context
courseType := detectCurrentCourse()
if courseType == "" {
fmt.Println("❌ Could not detect current course. Please run from a PowerShell Skills course directory.")
return
}

hints, exists := powerShellHints[courseType]
if !exists {
fmt.Printf("❌ No hints available for course type: %s\n", courseType)
return
}

// Select a random hint from the appropriate course
rand.Seed(time.Now().UnixNano())
hint := hints[rand.Intn(len(hints))]

fmt.Printf("🎯 Topic: %s\n\n", hint.Title)
fmt.Printf("📝 Explanation:\n%s\n\n", hint.Description)
fmt.Printf("💻 Example:\n%s\n\n", hint.Example)
fmt.Printf("📚 Learn More: %s\n\n", hint.Reference)

// Additional context-aware tips
fmt.Println("🔧 Pro Tips:")
switch courseType {
case "fundamentals":
fmt.Println("• Use Get-Help <command> to learn about any PowerShell command")
fmt.Println("• PowerShell is case-insensitive for commands and variables")
fmt.Println("• Use tab completion to discover available commands and parameters")
case "pipelines":
fmt.Println("• Remember: PowerShell passes objects, not text through the pipeline")
fmt.Println("• Use Get-Member to explore object properties and methods")
fmt.Println("• ForEach-Object processes each pipeline object individually")
case "functions":
fmt.Println("• Always include [CmdletBinding()] for advanced function features")
fmt.Println("• Use Write-Verbose for debugging instead of Write-Host")
fmt.Println("• Return objects, not formatted text from functions")
case "automation":
fmt.Println("• Use PowerShell classes for complex data structures")
fmt.Println("• Implement proper error handling with try/catch/finally")
fmt.Println("• Consider security implications when automating sensitive operations")
}

fmt.Println("\n🚀 Ready to continue? Use ''gh pwsh-skills validate'' to test your solution!")
}

func detectCurrentCourse() string {
	// Use the shared course detection logic
	currentCourse := DetectCurrentCourseInfo()
	if currentCourse == nil {
		return ""
	}
	
	// Map course names to hint categories
	switch currentCourse.Index {
	case 0:
		return "fundamentals"
	case 1:
		return "pipelines"
	case 2:
		return "functions"
	case 3:
		return "automation"
	default:
		return ""
	}
}

func init() {
	rootCmd.AddCommand(hintCmd)
}
