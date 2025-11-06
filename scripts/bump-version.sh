#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS] VERSION_TYPE"
    echo ""
    echo "VERSION_TYPE:"
    echo "  major     Increment major version (1.0.0 -> 2.0.0)"
    echo "  minor     Increment minor version (1.0.0 -> 1.1.0)"
    echo "  patch     Increment patch version (1.0.0 -> 1.0.1)"
    echo "  <version> Set specific version (e.g., 1.2.3)"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help     Show this help message"
    echo "  -n, --dry-run  Show what would be done without making changes"
    echo "  -p, --push     Push the tag to remote after creating"
    echo ""
    echo "Examples:"
    echo "  $0 patch          # Bump patch version"
    echo "  $0 minor          # Bump minor version"
    echo "  $0 1.2.3          # Set specific version"
    echo "  $0 -p patch       # Bump patch and push tag"
}

# Parse command line arguments
DRY_RUN=false
PUSH_TAG=false
VERSION_TYPE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -p|--push)
            PUSH_TAG=true
            shift
            ;;
        *)
            if [[ -z "$VERSION_TYPE" ]]; then
                VERSION_TYPE="$1"
            else
                echo -e "${RED}Error: Multiple version types specified${NC}"
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$VERSION_TYPE" ]]; then
    echo -e "${RED}Error: Version type is required${NC}"
    show_help
    exit 1
fi

# Get current version from git tags
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo -e "${BLUE}Current version: ${CURRENT_VERSION}${NC}"

# Remove 'v' prefix for version manipulation
CURRENT_VERSION_NO_V=${CURRENT_VERSION#v}

# Parse version numbers
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION_NO_V"
MAJOR=${VERSION_PARTS[0]:-0}
MINOR=${VERSION_PARTS[1]:-0}
PATCH=${VERSION_PARTS[2]:-0}

# Calculate new version
case $VERSION_TYPE in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_PATCH=0
        NEW_VERSION="v${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
        ;;
    minor)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_PATCH=0
        NEW_VERSION="v${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
        ;;
    patch)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$((PATCH + 1))
        NEW_VERSION="v${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
        ;;
    *)
        # Assume it's a specific version
        if [[ $VERSION_TYPE =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            if [[ $VERSION_TYPE == v* ]]; then
                NEW_VERSION="$VERSION_TYPE"
            else
                NEW_VERSION="v$VERSION_TYPE"
            fi
        else
            echo -e "${RED}Error: Invalid version format. Use major/minor/patch or x.y.z${NC}"
            exit 1
        fi
        ;;
esac

echo -e "${GREEN}New version: ${NEW_VERSION}${NC}"

if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}DRY RUN - The following actions would be performed:${NC}"
    echo "1. Create git tag: $NEW_VERSION"
    if [[ "$PUSH_TAG" == "true" ]]; then
        echo "2. Push tag to remote: git push origin $NEW_VERSION"
    fi
    exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check if working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}Warning: Working directory is not clean${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create the tag
echo -e "${BLUE}Creating tag ${NEW_VERSION}...${NC}"
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"

echo -e "${GREEN}✅ Tag ${NEW_VERSION} created successfully${NC}"

# Push the tag if requested
if [[ "$PUSH_TAG" == "true" ]]; then
    echo -e "${BLUE}Pushing tag to remote...${NC}"
    git push origin "$NEW_VERSION"
    echo -e "${GREEN}✅ Tag pushed to remote${NC}"
    echo -e "${BLUE}Release pipeline should start automatically${NC}"
fi

echo -e "${GREEN}🚀 Version bump complete!${NC}"
echo -e "${BLUE}To push manually later: git push origin ${NEW_VERSION}${NC}"
