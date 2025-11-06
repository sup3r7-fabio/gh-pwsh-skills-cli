#!/bin/bash

# Enhanced Release Script for gh-pwsh-skills
# Usage: ./scripts/manual-release.sh [options]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}[RELEASE]${NC} $1"
}

print_prompt() {
    echo -e "${CYAN}[INPUT]${NC} $1"
}

# Default values
RELEASE_TYPE=""
VERSION_INCREMENT=""
CUSTOM_VERSION=""
BETA_VERSION=""
CREATE_PRERELEASE="true"
SKIP_TESTS="false"
DRY_RUN="false"
INTERACTIVE="true"

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Enhanced release script for gh-pwsh-skills with support for multiple release types.

OPTIONS:
    -t, --type TYPE           Release type: beta, release-candidate, stable, hotfix
    -i, --increment INC       Version increment: auto, major, minor, patch
    -v, --version VERSION     Custom version (overrides increment)
    -b, --beta-suffix SUFFIX  Beta version suffix (for beta/rc releases)
    -p, --prerelease BOOL     Create as prerelease (true/false)
    -s, --skip-tests          Skip running tests
    -d, --dry-run            Perform dry run without publishing
    -n, --non-interactive    Run without prompts
    -h, --help               Show this help message

EXAMPLES:
    # Interactive mode (default)
    $0

    # Create a beta release
    $0 --type beta --increment patch

    # Create a stable release with custom version
    $0 --type stable --version 1.2.3

    # Create a release candidate with dry run
    $0 --type release-candidate --increment minor --dry-run

    # Create a hotfix release
    $0 --type hotfix --increment patch --skip-tests

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            RELEASE_TYPE="$2"
            shift 2
            ;;
        -i|--increment)
            VERSION_INCREMENT="$2"
            shift 2
            ;;
        -v|--version)
            CUSTOM_VERSION="$2"
            shift 2
            ;;
        -b|--beta-suffix)
            BETA_VERSION="$2"
            shift 2
            ;;
        -p|--prerelease)
            CREATE_PRERELEASE="$2"
            shift 2
            ;;
        -s|--skip-tests)
            SKIP_TESTS="true"
            shift
            ;;
        -d|--dry-run)
            DRY_RUN="true"
            shift
            ;;
        -n|--non-interactive)
            INTERACTIVE="false"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if we're in the right directory
if [[ ! -f "go.mod" ]] || [[ ! -f ".github/workflows/beta-release.yml" ]]; then
    print_error "This script must be run from the root of the gh-pwsh-skills project"
    exit 1
fi

print_header "🚀 Enhanced Release Manager for gh-pwsh-skills"
echo

# Interactive mode
if [[ "$INTERACTIVE" == "true" ]]; then
    if [[ -z "$RELEASE_TYPE" ]]; then
        print_prompt "Select release type:"
        echo "  1) beta - Beta release for testing"
        echo "  2) release-candidate - Release candidate for final testing" 
        echo "  3) stable - Stable production release"
        echo "  4) hotfix - Urgent bug fix release"
        echo
        read -p "Choice (1-4): " -n 1 -r
        echo
        case $REPLY in
            1) RELEASE_TYPE="beta" ;;
            2) RELEASE_TYPE="release-candidate" ;;
            3) RELEASE_TYPE="stable" ;;
            4) RELEASE_TYPE="hotfix" ;;
            *) print_error "Invalid choice"; exit 1 ;;
        esac
    fi

    if [[ -z "$VERSION_INCREMENT" && -z "$CUSTOM_VERSION" ]]; then
        print_prompt "Select version strategy:"
        echo "  1) auto - Auto-detect from commit messages"
        echo "  2) patch - Increment patch version (1.0.0 -> 1.0.1)"
        echo "  3) minor - Increment minor version (1.0.0 -> 1.1.0)"
        echo "  4) major - Increment major version (1.0.0 -> 2.0.0)"
        echo "  5) custom - Enter custom version"
        echo
        read -p "Choice (1-5): " -n 1 -r
        echo
        case $REPLY in
            1) VERSION_INCREMENT="auto" ;;
            2) VERSION_INCREMENT="patch" ;;
            3) VERSION_INCREMENT="minor" ;;
            4) VERSION_INCREMENT="major" ;;
            5) 
                read -p "Enter custom version (e.g., 1.2.3): " CUSTOM_VERSION
                ;;
            *) print_error "Invalid choice"; exit 1 ;;
        esac
    fi

    if [[ ("$RELEASE_TYPE" == "beta" || "$RELEASE_TYPE" == "release-candidate") && -z "$BETA_VERSION" ]]; then
        read -p "Enter beta suffix (default: beta): " BETA_INPUT
        BETA_VERSION=${BETA_INPUT:-beta}
    fi

    if [[ "$RELEASE_TYPE" != "stable" ]]; then
        read -p "Create as prerelease? (Y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            CREATE_PRERELEASE="false"
        fi
    else
        CREATE_PRERELEASE="false"
    fi

    read -p "Skip tests? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        SKIP_TESTS="true"
        print_warning "Skipping tests is not recommended!"
    fi

    read -p "Perform dry run? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        DRY_RUN="true"
    fi
fi

# Validate required parameters
if [[ -z "$RELEASE_TYPE" ]]; then
    print_error "Release type is required"
    exit 1
fi

if [[ -z "$VERSION_INCREMENT" && -z "$CUSTOM_VERSION" ]]; then
    VERSION_INCREMENT="auto"
fi

# Set defaults for beta version
if [[ ("$RELEASE_TYPE" == "beta" || "$RELEASE_TYPE" == "release-candidate") && -z "$BETA_VERSION" ]]; then
    BETA_VERSION="beta"
fi

print_header "Release Configuration"
echo "  🎯 Type: $RELEASE_TYPE"
echo "  📊 Version Strategy: ${CUSTOM_VERSION:+Custom ($CUSTOM_VERSION)}${VERSION_INCREMENT:+Increment ($VERSION_INCREMENT)}"
if [[ -n "$BETA_VERSION" ]]; then
    echo "  🧪 Beta Suffix: $BETA_VERSION"
fi
echo "  🏷️  Prerelease: $CREATE_PRERELEASE"
echo "  🧪 Skip Tests: $SKIP_TESTS"
echo "  🔍 Dry Run: $DRY_RUN"
echo

# Confirm before proceeding
if [[ "$INTERACTIVE" == "true" ]]; then
    read -p "Proceed with this configuration? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_error "Aborted by user"
        exit 1
    fi
fi

# Check working directory
if [[ -n $(git status --porcelain) ]]; then
    print_warning "Working directory is not clean. Uncommitted changes:"
    git status --short
    echo
    if [[ "$INTERACTIVE" == "true" ]]; then
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Aborted by user"
            exit 1
        fi
    fi
fi

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed. Please install it first:"
    print_error "https://github.com/cli/cli#installation"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    print_error "Not authenticated with GitHub CLI. Please run 'gh auth login' first."
    exit 1
fi

# Fetch latest changes
print_status "Fetching latest changes..."
git fetch origin

# Build arguments for workflow dispatch
ARGS=(
    "--field" "release_type=$RELEASE_TYPE"
    "--field" "create_prerelease=$CREATE_PRERELEASE"
    "--field" "skip_tests=$SKIP_TESTS"
    "--field" "dry_run=$DRY_RUN"
)

if [[ -n "$CUSTOM_VERSION" ]]; then
    ARGS+=("--field" "custom_version=$CUSTOM_VERSION")
else
    ARGS+=("--field" "version_increment=$VERSION_INCREMENT")
fi

if [[ -n "$BETA_VERSION" ]]; then
    ARGS+=("--field" "beta_version=$BETA_VERSION")
fi

# Trigger the workflow
print_status "Triggering release workflow..."
print_status "Command: gh workflow run beta-release.yml ${ARGS[*]}"

if gh workflow run beta-release.yml "${ARGS[@]}"; then
    print_success "Release workflow triggered successfully!"
    echo
    print_status "🔗 Monitor progress at:"
    echo "https://github.com/sup3r7-fabio/gh-pwsh-skills/actions"
    echo
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "This is a DRY RUN - no actual release will be published"
    else
        print_status "📦 Once completed, the release will be available at:"
        echo "https://github.com/sup3r7-fabio/gh-pwsh-skills/releases"
    fi
    
    echo
    print_status "🎯 Release Type: $RELEASE_TYPE"
    
    case "$RELEASE_TYPE" in
        beta)
            print_status "🧪 This is a BETA release - gather feedback from testers"
            ;;
        release-candidate)
            print_status "🚀 This is a RELEASE CANDIDATE - final testing before stable"
            ;;
        stable)
            print_status "✅ This is a STABLE release - ready for production"
            ;;
        hotfix)
            print_status "🔥 This is a HOTFIX release - urgent bug fixes included"
            ;;
    esac
else
    print_error "Failed to trigger release workflow"
    exit 1
fi

echo
print_success "Release process initiated successfully!"
print_status "Next steps:"
echo "  1. 🔍 Monitor the GitHub Actions workflow"
echo "  2. 🧪 Test the release once it's published"
echo "  3. 📢 Announce the release to users"
echo "  4. 📝 Update documentation if needed"
