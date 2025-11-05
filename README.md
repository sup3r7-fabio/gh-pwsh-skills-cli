# GitHub CLI PowerShell Skills Extension

A GitHub CLI extension that enhances your PowerShell GitHub Skills learning experience with interactive progress tracking, contextual hints, and local validation.

## 🚀 Features

- **📊 Progress Tracking**: Visual progress bars showing completion across all courses
- **💡 Contextual Hints**: Smart hints based on your current course and step
- **🧪 Local Validation**: Test PowerShell syntax and cross-platform compatibility before committing
- **🔍 Course Detection**: Automatically detects which PowerShell Skills course you''re working on
- **✅ Best Practices**: Suggestions for PowerShell coding standards

## 📦 Installation

### Prerequisites
- [GitHub CLI](https://cli.github.com/) installed
- [PowerShell 7+](https://github.com/PowerShell/PowerShell#get-powershell) (recommended for cross-platform compatibility)
- Git repository with PowerShell GitHub Skills courses

### Install Extension

```bash
# Clone and install the extension
gh extension install sup3r7-fabio/gh-pwsh-skills
```

Or install from source:

```bash
# Clone the repository
git clone https://github.com/sup3r7-fabio/gh-pwsh-skills.git
cd gh-pwsh-skills

# Build and install
go build -o gh-pwsh-skills
gh extension install .
```

## 🎯 Usage

Navigate to your PowerShell GitHub Skills course directory and use these commands:

### Check Progress
```bash
gh pwsh-skills status
```
Shows visual progress across all detected courses with completion percentages and time estimates.

### Get Contextual Hints
```bash
gh pwsh-skills hint
```
Provides relevant PowerShell tips, examples, and documentation links based on your current course.

### Validate Solutions
```bash
gh pwsh-skills validate
```
Tests your PowerShell code for:
- Syntax validation
- Cross-platform compatibility
- PowerShell best practices
- Common mistakes

### Help
```bash
gh pwsh-skills --help
```
Shows all available commands and options.

## 📚 Supported Courses

This extension works with the complete PowerShell GitHub Skills series:

1. **Course 1: PowerShell Fundamentals**
   - Variables, operators, conditionals, loops
   - Basic cmdlets and pipeline introduction

2. **Course 2: Pipelines & Filtering** 
   - Object-oriented pipeline processing
   - Filtering, sorting, and data transformation

3. **Course 3: Functions & Modules**
   - Advanced function development
   - Module creation and distribution

4. **Course 4: Automation & DevOps**
   - Enterprise automation patterns
   - Infrastructure as Code with PowerShell

## 🛠️ Development

### Build from Source
```bash
git clone https://github.com/sup3r7-fabio/gh-pwsh-skills.git
cd gh-pwsh-skills
go mod tidy
go build -o gh-pwsh-skills
```

### Run Tests
```bash
go test ./...
```

### Project Structure
```
gh-pwsh-skills/
├── cmd/                    # CLI command implementations
│   ├── root.go            # Root command and CLI setup
│   ├── status.go          # Progress tracking functionality
│   ├── hint.go            # Contextual hint system
│   └── validate.go        # PowerShell validation engine
├── internal/              # Internal packages
│   ├── github/           # GitHub API integration
│   ├── parser/           # YAML workflow parsing
│   ├── validator/        # PowerShell validation logic
│   └── progress/         # Progress tracking utilities
├── templates/            # Hint and solution templates
└── main.go              # Application entry point
```

## 🎨 Example Output

### Status Command
```
📍 PowerShell GitHub Skills - Progress Status
==============================================
📂 Repository: sup3r7-fabio/pwsh-github-skills-tutorial

🎯 Course Progress:
  🔄 Course 1: PowerShell Fundamentals
     Progress: [██░░░] 2/5 steps
     ⏱️  Estimated time remaining: 30 minutes

  ✅ Course 2: Pipelines & Filtering  
     Progress: [█████] 5/5 steps

🏆 Overall Progress: 1/4 courses completed (25.0%)
```

### Hint Command
```
💡 PowerShell GitHub Skills - Contextual Hint
============================================
🎯 Topic: Pipeline Basics

📝 Explanation:
PowerShell pipeline passes objects, not text. Use | to chain commands

💻 Example:
Get-Process | Where-Object { $_.CPU -gt 100 } | Select-Object Name, CPU

📚 Learn More: https://docs.microsoft.com/powershell/scripting/learn/understanding-the-powershell-pipeline

🔧 Pro Tips:
• Remember: PowerShell passes objects, not text through the pipeline
• Use Get-Member to explore object properties and methods
• ForEach-Object processes each pipeline object individually
```

### Validate Command
```
🧪 PowerShell Solution Validation
=================================
✅ PowerShell detected
🔍 Found 1 PowerShell file(s) to validate:
   • step-2-solution.ps1

🔍 Validating: step-2-solution.ps1
  ✅ Syntax: Valid
  ✅ Cross-platform: Compatible
  💡 Best practice suggestions:
     • Consider adding [CmdletBinding()] to functions
✅ step-2-solution.ps1 - All checks passed

🎉 All validations passed!
🚀 Your solution is ready to commit and push!
```

## 🤝 Contributing

Contributions are welcome! Please feel free to:

1. Report bugs and suggest features via [Issues](https://github.com/sup3r7-fabio/gh-pwsh-skills/issues)
2. Submit pull requests with improvements
3. Add more PowerShell hints and validation rules
4. Improve course detection logic

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [GitHub Skills](https://skills.github.com/) for the excellent learning platform
- [PowerShell Team](https://github.com/PowerShell/PowerShell) for the amazing shell
- [GitHub CLI](https://cli.github.com/) for the extensible CLI framework
- [Cobra](https://github.com/spf13/cobra) for the CLI library
