#!/bin/bash

# Semver Tag Creator for gh-pwsh-skills
# Usage: ./scripts/create-semver-tag.sh [options]

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
    echo -e "${PURPLE}[SEMVER]${NC} $1"
}

print_prompt() {
    echo -e "${CYAN}[INPUT]${NC} $1"
}

# Default values
RELEASE_TYPE=""
VERSION=""
PRERELEASE_TYPE=""
PRERELEASE_NUMBER=""
AUTO_INCREMENT="false"
DRY_RUN="false"
INTERACTIVE="true"
PUSH_TAG="true"

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Create semver-compliant tags for automatic releases.

SEMVER TAG FORMATS:
    Stable:      v1.2.3
    Alpha:       v1.2.3-alpha.1
    Beta:        v1.2.3-beta.1  
    RC:          v1.2.3-rc.1
    Development: v1.2.3-dev.123
    Nightly:     v1.2.3-nightly.456

OPTIONS:
    -t, --type TYPE          Release type: stable, alpha, beta, rc, dev, nightly
    -v, --version VERSION    Exact version (e.g., 1.2.3)
    -i, --increment TYPE     Auto increment: major, minor, patch
    -p, --prerelease NUM     Prerelease number (for non-stable releases)
    -d, --dry-run           Show what would be created without creating
    -n, --no-push          Create tag locally but don't push
    --non-interactive       Run without prompts
    -h, --help              Show this help message

EXAMPLES:
    # Interactive mode (recommended)
    $0

    # Create stable release v1.2.3
    $0 --type stable --version 1.2.3

    # Auto-increment patch version for beta
    $0 --type beta --increment patch --prerelease 1

    # Create development tag with dry run
    $0 --type dev --increment minor --prerelease 123 --dry-run

    # Create RC without pushing
    $0 --type rc --version 2.0.0 --prerelease 1 --no-push

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            RELEASE_TYPE="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -i|--increment)
            AUTO_INCREMENT="$2"
            shift 2
            ;;
        -p|--prerelease)
            PRERELEASE_NUMBER="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN="true"
            shift
            ;;
        -n|--no-push)
            PUSH_TAG="false"
            shift
            ;;
        --non-interactive)
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
if [[ ! -f "go.mod" ]] || [[ ! -f ".github/workflows/release-on-tag.yml" ]]; then
    print_error "This script must be run from the root of the gh-pwsh-skills project"
    exit 1
fi

print_header "🏷️  Semver Tag Creator for gh-pwsh-skills"
echo

# Get current version info
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
LATEST_VERSION=${LATEST_TAG#v}

echo "📋 Current repository state:"
echo "  Latest tag: $LATEST_TAG"
echo "  Latest version: $LATEST_VERSION"

# Parse current version
if [[ $LATEST_VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    CURRENT_MAJOR=${BASH_REMATCH[1]}
    CURRENT_MINOR=${BASH_REMATCH[2]}
    CURRENT_PATCH=${BASH_REMATCH[3]}
    echo "  Parsed: $CURRENT_MAJOR.$CURRENT_MINOR.$CURRENT_PATCH"
else
    CURRENT_MAJOR=0
    CURRENT_MINOR=0
    CURRENT_PATCH=0
    print_warning "Could not parse current version, starting from 0.0.0"
fi

echo

# Interactive mode
if [[ "$INTERACTIVE" == "true" ]]; then
    if [[ -z "$RELEASE_TYPE" ]]; then
        print_prompt "Select release type:"
        echo "  1) stable      - Production release (v1.2.3)"
        echo "  2) beta        - Beta testing (v1.2.3-beta.1)"
        echo "  3) alpha       - Alpha testing (v1.2.3-alpha.1)"
        echo "  4) rc          - Release candidate (v1.2.3-rc.1)"
        echo "  5) dev         - Development build (v1.2.3-dev.123)"
        echo "  6) nightly     - Nightly build (v1.2.3-nightly.456)"
        echo
        read -p "Choice (1-6): " -n 1 -r
        echo
        case $REPLY in
            1) RELEASE_TYPE="stable" ;;
            2) RELEASE_TYPE="beta" ;;
            3) RELEASE_TYPE="alpha" ;;
            4) RELEASE_TYPE="rc" ;;
            5) RELEASE_TYPE="dev" ;;
            6) RELEASE_TYPE="nightly" ;;
            *) print_error "Invalid choice"; exit 1 ;;
        esac
    fi

    if [[ -z "$VERSION" && "$AUTO_INCREMENT" == "false" ]]; then
        print_prompt "Version strategy:"
        echo "  1) auto-major  - ${CURRENT_MAJOR}.${CURRENT_MINOR}.${CURRENT_PATCH} → $((CURRENT_MAJOR + 1)).0.0"
        echo "  2) auto-minor  - ${CURRENT_MAJOR}.${CURRENT_MINOR}.${CURRENT_PATCH} → ${CURRENT_MAJOR}.$((CURRENT_MINOR + 1)).0"
        echo "  3) auto-patch  - ${CURRENT_MAJOR}.${CURRENT_MINOR}.${CURRENT_PATCH} → ${CURRENT_MAJOR}.${CURRENT_MINOR}.$((CURRENT_PATCH + 1))"
        echo "  4) custom      - Enter custom version"
        echo
        read -p "Choice (1-4): " -n 1 -r
        echo
        case $REPLY in
            1) AUTO_INCREMENT="major" ;;
            2) AUTO_INCREMENT="minor" ;;
            3) AUTO_INCREMENT="patch" ;;
            4) 
                read -p "Enter version (e.g., 1.2.3): " VERSION
                # Validate version format
                if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    print_error "Invalid version format. Use: major.minor.patch (e.g., 1.2.3)"
                    exit 1
                fi
                ;;
            *) print_error "Invalid choice"; exit 1 ;;
        esac
    fi

    if [[ "$RELEASE_TYPE" != "stable" && -z "$PRERELEASE_NUMBER" ]]; then
        # Suggest next prerelease number
        LATEST_PRERELEASE=$(git tag -l "*-${RELEASE_TYPE}.*" --sort=-version:refname | head -n1 || echo "")
        if [[ -n "$LATEST_PRERELEASE" ]]; then
            if [[ $LATEST_PRERELEASE =~ -${RELEASE_TYPE}\.([0-9]+) ]]; then
                SUGGESTED_NUMBER=$((${BASH_REMATCH[1]} + 1))
            else
                SUGGESTED_NUMBER=1
            fi
        else
            SUGGESTED_NUMBER=1
        fi
        
        read -p "Enter ${RELEASE_TYPE} number (suggested: $SUGGESTED_NUMBER): " PRERELEASE_INPUT
        PRERELEASE_NUMBER=${PRERELEASE_INPUT:-$SUGGESTED_NUMBER}
    fi
    
    read -p "Push tag to remote? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        PUSH_TAG="false"
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

# Calculate version if auto-increment is used
if [[ "$AUTO_INCREMENT" != "false" && -z "$VERSION" ]]; then
    case "$AUTO_INCREMENT" in
        major)
            NEW_MAJOR=$((CURRENT_MAJOR + 1))
            VERSION="$NEW_MAJOR.0.0"
            ;;
        minor)
            NEW_MINOR=$((CURRENT_MINOR + 1))
            VERSION="$CURRENT_MAJOR.$NEW_MINOR.0"
            ;;
        patch)
            NEW_PATCH=$((CURRENT_PATCH + 1))
            VERSION="$CURRENT_MAJOR.$CURRENT_MINOR.$NEW_PATCH"
            ;;
        *)
            print_error "Invalid increment type: $AUTO_INCREMENT"
            exit 1
            ;;
    esac
fi

if [[ -z "$VERSION" ]]; then
    print_error "Version is required (use --version or --increment)"
    exit 1
fi

# Build the final tag
if [[ "$RELEASE_TYPE" == "stable" ]]; then
    FINAL_TAG="v$VERSION"
else
    if [[ -z "$PRERELEASE_NUMBER" ]]; then
        print_error "Prerelease number is required for non-stable releases"
        exit 1
    fi
    FINAL_TAG="v$VERSION-$RELEASE_TYPE.$PRERELEASE_NUMBER"
fi

# Validate semver format
if [[ ! $FINAL_TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+\.[0-9]+)?$ ]]; then
    print_error "Generated tag does not match semver format: $FINAL_TAG"
    exit 1
fi

print_header "Tag Configuration"
echo "  🎯 Release Type: $RELEASE_TYPE"
echo "  📋 Version: $VERSION"
if [[ "$RELEASE_TYPE" != "stable" ]]; then
    echo "  🧪 Prerelease: $PRERELEASE_NUMBER"
fi
echo "  🏷️  Final Tag: $FINAL_TAG"
echo "  📤 Push to Remote: $PUSH_TAG"
echo "  🔍 Dry Run: $DRY_RUN"
echo

# Check if tag already exists
if git rev-parse "$FINAL_TAG" >/dev/null 2>&1; then
    print_error "Tag $FINAL_TAG already exists!"
    print_status "Existing tags:"
    git tag -l "*" --sort=-version:refname | head -10
    exit 1
fi

# Confirm before proceeding
if [[ "$INTERACTIVE" == "true" ]]; then
    read -p "Create tag $FINAL_TAG? (Y/n): " -n 1 -r
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
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Aborted by user"
            exit 1
        fi
    fi
fi

if [[ "$DRY_RUN" == "true" ]]; then
    print_header "🧪 DRY RUN - No changes will be made"
    echo "Would create tag: $FINAL_TAG"
    if [[ "$PUSH_TAG" == "true" ]]; then
        echo "Would push tag to origin"
    else
        echo "Would create local tag only"
    fi
    echo "This would trigger the release-on-tag.yml workflow"
    exit 0
fi

# Create the tag
print_status "Creating tag $FINAL_TAG..."
if git tag -a "$FINAL_TAG" -m "Release $FINAL_TAG

Release Type: $RELEASE_TYPE
Version: $VERSION$(if [[ "$RELEASE_TYPE" != "stable" ]]; then echo "
Prerelease: $PRERELEASE_NUMBER"; fi)

Generated by create-semver-tag.sh"; then
    print_success "Tag $FINAL_TAG created successfully!"
else
    print_error "Failed to create tag $FINAL_TAG"
    exit 1
fi

# Push the tag if requested
if [[ "$PUSH_TAG" == "true" ]]; then
    print_status "Pushing tag to origin..."
    if git push origin "$FINAL_TAG"; then
        print_success "Tag pushed successfully!"
        echo
        print_status "🚀 Release workflow will be triggered automatically"
        print_status "Monitor progress at: https://github.com/sup3r7-fabio/gh-pwsh-skills/actions"
        print_status "Release will be available at: https://github.com/sup3r7-fabio/gh-pwsh-skills/releases"
    else
        print_error "Failed to push tag"
        print_warning "Tag created locally but not pushed"
        print_status "You can push it manually later with: git push origin $FINAL_TAG"
        exit 1
    fi
else
    print_success "Tag created locally"
    print_status "Push when ready with: git push origin $FINAL_TAG"
fi

echo
print_success "Semver tag creation complete!"
print_status "Tag: $FINAL_TAG"
case "$RELEASE_TYPE" in
    stable)
        print_status "🎉 This will create a STABLE release"
        ;;
    alpha)
        print_status "🧪 This will create an ALPHA release"
        ;;
    beta)
        print_status "🧪 This will create a BETA release"
        ;;
    rc)
        print_status "🚀 This will create a RELEASE CANDIDATE"
        ;;
    dev)
        print_status "⚡ This will create a DEVELOPMENT release"
        ;;
    nightly)
        print_status "🌙 This will create a NIGHTLY release"
        ;;
esac
