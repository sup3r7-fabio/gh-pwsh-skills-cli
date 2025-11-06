#!/bin/bash

# Beta Release Script for gh-pwsh-skills
# Usage: ./scripts/beta-release.sh [beta-suffix] [--prerelease]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Check if we're in the right directory
if [[ ! -f "go.mod" ]] || [[ ! -f ".goreleaser.beta.yml" ]]; then
    print_error "This script must be run from the root of the gh-pwsh-skills project"
    exit 1
fi

# Parse arguments
BETA_SUFFIX=${1:-""}
CREATE_PRERELEASE=${2:-"--prerelease"}

# If no beta suffix provided, generate one
if [[ -z "$BETA_SUFFIX" ]]; then
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    COMMIT_SHORT=$(git rev-parse --short HEAD)
    BETA_SUFFIX="beta.${TIMESTAMP}.${COMMIT_SHORT}"
fi

print_status "Starting beta release process..."
print_status "Beta suffix: $BETA_SUFFIX"

# Check if working directory is clean
if [[ -n $(git status --porcelain) ]]; then
    print_warning "Working directory is not clean. Uncommitted changes:"
    git status --short
    echo
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Aborted by user"
        exit 1
    fi
fi

# Ensure we're on the latest commit
print_status "Fetching latest changes..."
git fetch origin

# Check if we're ahead of origin
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
if [[ "$AHEAD" -gt 0 ]]; then
    print_warning "Your local branch is $AHEAD commits ahead of origin"
    read -p "Do you want to push first? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Pushing changes..."
        git push
    fi
fi

# Run tests before release
print_status "Running tests..."
if ! go test ./...; then
    print_error "Tests failed! Please fix them before creating a beta release."
    exit 1
fi

print_success "Tests passed!"

# Build to ensure everything compiles
print_status "Building project..."
if ! go build ./...; then
    print_error "Build failed! Please fix compilation errors before creating a beta release."
    exit 1
fi

print_success "Build successful!"

# Trigger the beta release workflow
print_status "Triggering beta release workflow..."

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed. Please install it first:"
    print_error "https://github.com/cli/cli#installation"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    print_error "Not authenticated with GitHub CLI. Please run 'gh auth login' first."
    exit 1
fi

# Trigger the workflow
print_status "Triggering GitHub Actions workflow..."
if gh workflow run beta-release.yml \
    --field beta_version="$BETA_SUFFIX" \
    --field create_prerelease="true"; then
    print_success "Beta release workflow triggered successfully!"
    echo
    print_status "You can monitor the progress at:"
    echo "https://github.com/sup3r7-fabio/gh-pwsh-skills/actions"
    echo
    print_status "Once completed, the beta release will be available at:"
    echo "https://github.com/sup3r7-fabio/gh-pwsh-skills/releases"
    echo
    print_status "Users can install the beta with:"
    echo "gh extension install sup3r7-fabio/gh-pwsh-skills"
else
    print_error "Failed to trigger beta release workflow"
    exit 1
fi

echo
print_success "Beta release process initiated!"
print_status "Next steps:"
echo "  1. Monitor the GitHub Actions workflow"
echo "  2. Test the beta release once it's published"
echo "  3. Gather feedback from beta users"
echo "  4. Create a full release when ready"
