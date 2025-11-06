# Semver Tag-Based Release System

This document describes the semantic versioning (semver) tag-based release system for `gh-pwsh-skills`. This system automatically creates releases when properly formatted semver tags are pushed to the repository.

## 🏷️ Overview

The release system is triggered **only** when tags following semantic versioning standards are pushed. No manual workflow dispatches or branch pushes trigger releases - everything is controlled by tags.

## 📋 Supported Tag Formats

### Semver Standard Formats

All tags must follow the pattern `v{MAJOR}.{MINOR}.{PATCH}[-{PRERELEASE}.{NUMBER}]`

#### Stable Releases
```
v1.0.0        # Major release
v1.2.0        # Minor release  
v1.2.3        # Patch release
```

#### Pre-release Types
```
v1.2.3-alpha.1      # Alpha version (early testing)
v1.2.3-beta.1       # Beta version (feature complete)
v1.2.3-rc.1         # Release candidate (final testing)
v1.2.3-dev.123      # Development build
v1.2.3-nightly.456  # Nightly build
v1.2.3-hotfix.1     # Hotfix release
v1.2.3-build.789    # Custom build
```

## 🔧 Available Workflows

### 1. Strict Semver Release (`strict-semver-release.yml`)

**Triggers on**: `v1.2.3`, `v1.2.3-alpha.N`, `v1.2.3-beta.N`, `v1.2.3-rc.N`

**Features**:
- ✅ Only allows standard semver patterns
- ✅ Strict validation and version progression checks
- ✅ Suitable for production environments
- ❌ No development/nightly builds allowed

**Use Cases**: 
- Production releases
- Official pre-releases
- When strict semver compliance is required

### 2. Flexible Semver Release (`flexible-semver-release.yml`)

**Triggers on**: All semver patterns including dev, nightly, hotfix, build

**Features**:
- ✅ Supports extended semver patterns
- ✅ Allows development and nightly builds
- ✅ Comprehensive release type handling
- ✅ Flexible validation rules

**Use Cases**:
- Development workflows
- CI/CD with nightly builds
- Custom release requirements

### 3. Basic Tag Release (`release-on-tag.yml`)

**Triggers on**: All supported semver patterns with enhanced validation

**Features**:
- ✅ Comprehensive tag validation
- ✅ Automatic release type detection
- ✅ Smart configuration file selection
- ✅ Detailed release summaries

**Use Cases**:
- General purpose releases
- Mixed development and production workflow

## 🚀 Creating Releases

### Option 1: Use the Semver Tag Creator Script (Recommended)

```bash
# Interactive mode
./scripts/create-semver-tag.sh

# Quick examples
./scripts/create-semver-tag.sh --type stable --version 1.2.3
./scripts/create-semver-tag.sh --type beta --increment patch --prerelease 1
./scripts/create-semver-tag.sh --type rc --version 2.0.0 --prerelease 1 --dry-run
```

### Option 2: Manual Git Tags

```bash
# Create and push tags manually
git tag v1.2.3
git push origin v1.2.3

# Or create annotated tags with messages
git tag -a v1.2.3-beta.1 -m "Beta release v1.2.3-beta.1"
git push origin v1.2.3-beta.1
```

## 📊 Release Types and Behaviors

| Tag Pattern | Release Type | Prerelease | Config File | Use Case |
|-------------|--------------|------------|-------------|----------|
| `v1.2.3` | stable | No | `.goreleaser.yml` | Production release |
| `v1.2.3-alpha.N` | alpha | Yes | `.goreleaser.beta.yml` | Early testing |
| `v1.2.3-beta.N` | beta | Yes | `.goreleaser.beta.yml` | Feature testing |
| `v1.2.3-rc.N` | release-candidate | Yes | `.goreleaser.yml` | Final testing |
| `v1.2.3-dev.N` | development | Yes | `.goreleaser.beta.yml` | Dev builds |
| `v1.2.3-nightly.N` | nightly | Yes | `.goreleaser.beta.yml` | Automated builds |
| `v1.2.3-hotfix.N` | hotfix | No | `.goreleaser.yml` | Urgent fixes |
| `v1.2.3-build.N` | build | Yes | `.goreleaser.beta.yml` | Custom builds |

## 🔄 Version Progression Rules

### Semantic Versioning Guidelines

**Major Version (X.0.0)**:
- Breaking changes
- API changes that break backwards compatibility
- Architectural changes

**Minor Version (X.Y.0)**:
- New features
- New functionality that doesn't break existing code
- Deprecations (with backwards compatibility)

**Patch Version (X.Y.Z)**:
- Bug fixes
- Security patches  
- Documentation updates
- Performance improvements

### Pre-release Guidelines

**Alpha (`-alpha.N`)**:
- Very early development
- Major features incomplete
- API may change significantly
- Not recommended for production testing

**Beta (`-beta.N`)**:
- Feature complete
- API relatively stable
- Ready for wider testing
- Some bugs expected

**Release Candidate (`-rc.N`)**:
- Feature complete and tested
- Ready for production
- Final validation before stable release
- Should be very stable

## 🛠️ Workflow Details

### Tag Validation Process

1. **Format Validation**: Ensures tag matches semver pattern
2. **Component Validation**: Checks version numbers are reasonable
3. **Type Detection**: Determines release type from tag
4. **Configuration Selection**: Chooses appropriate GoReleaser config
5. **Progression Check**: Validates version advancement (optional)

### Release Process

1. **Tag Push**: Developer pushes semver tag
2. **Workflow Trigger**: GitHub Actions detects tag
3. **Validation**: Tag format and content validated
4. **Testing**: Full test suite runs
5. **Building**: GoReleaser builds binaries
6. **Release Creation**: GitHub release created
7. **Notification**: Release summary generated

### Error Handling

**Invalid Tag Format**:
```
❌ Invalid semver format: v1.2.3.4
Expected: v1.2.3 or v1.2.3-type.number
```

**Unsupported Pre-release Type**:
```
❌ Unsupported prerelease type: custom
Supported: alpha, beta, rc, dev, nightly, hotfix, build
```

**Duplicate Tag**:
```
❌ Tag v1.2.3 already exists!
```

## 📚 Examples and Use Cases

### Typical Development Workflow

```bash
# Start with development builds
./scripts/create-semver-tag.sh --type dev --version 1.0.0 --prerelease 1

# Create alpha for early testing
./scripts/create-semver-tag.sh --type alpha --version 1.0.0 --prerelease 1

# Move to beta for wider testing  
./scripts/create-semver-tag.sh --type beta --version 1.0.0 --prerelease 1

# Create release candidate
./scripts/create-semver-tag.sh --type rc --version 1.0.0 --prerelease 1

# Final stable release
./scripts/create-semver-tag.sh --type stable --version 1.0.0
```

### Hotfix Workflow

```bash
# Current stable: v1.2.3
# Critical bug found, need immediate fix

# Create hotfix release
./scripts/create-semver-tag.sh --type hotfix --version 1.2.4 --prerelease 1

# Or patch increment
./scripts/create-semver-tag.sh --type stable --increment patch
```

### Nightly Build Automation

```bash
# Automated nightly builds (can be scripted)
DATE=$(date +%Y%m%d)
./scripts/create-semver-tag.sh --type nightly --version 1.3.0 --prerelease $DATE --non-interactive
```

### Feature Release Cycle

```bash
# New minor version with features
./scripts/create-semver-tag.sh --type beta --increment minor --prerelease 1    # v1.3.0-beta.1
./scripts/create-semver-tag.sh --type beta --version 1.3.0 --prerelease 2     # v1.3.0-beta.2
./scripts/create-semver-tag.sh --type rc --version 1.3.0 --prerelease 1       # v1.3.0-rc.1
./scripts/create-semver-tag.sh --type stable --version 1.3.0                  # v1.3.0
```

## 🔧 Configuration Files

### `.goreleaser.yml` (Production)
Used for:
- Stable releases (`v1.2.3`)
- Release candidates (`v1.2.3-rc.N`)
- Hotfix releases (`v1.2.3-hotfix.N`)

### `.goreleaser.beta.yml` (Pre-release)
Used for:
- Alpha releases (`v1.2.3-alpha.N`)
- Beta releases (`v1.2.3-beta.N`)
- Development builds (`v1.2.3-dev.N`)
- Nightly builds (`v1.2.3-nightly.N`)
- Custom builds (`v1.2.3-build.N`)

## 🚨 Important Notes

### Tag Immutability
- ⚠️ **Never delete or modify pushed tags** - this breaks release history
- ⚠️ **Tags trigger immediate releases** - ensure they're correct before pushing
- ⚠️ **Failed releases cannot be easily retried** with the same tag

### Version Strategy
- 📈 **Always increment versions** - never reuse version numbers
- 🔄 **Follow semver rules** - breaking changes require major version bump
- 📝 **Document changes** - maintain CHANGELOG.md for all releases

### Testing Strategy
- 🧪 **Use alpha/beta for testing** - don't skip testing phases
- ✅ **Test release candidates thoroughly** - they should be production-ready
- 🚫 **Don't use stable tags for testing** - they're considered production releases

## 🛟 Troubleshooting

### Common Issues

**"Tag already exists"**:
```bash
# Check existing tags
git tag -l --sort=-version:refname | head -10

# Delete local tag if needed (before pushing)
git tag -d v1.2.3
```

**"Invalid semver format"**:
```bash
# Check tag format
echo "v1.2.3-beta.1" | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+\.[0-9]+)?$'
```

**"Release workflow failed"**:
1. Check GitHub Actions logs
2. Verify GoReleaser configuration
3. Ensure all tests pass
4. Check repository permissions

### Recovery Procedures

**Failed Release with Existing Tag**:
1. Don't delete the tag (breaks history)
2. Create a new patch version tag
3. Document the issue in release notes

**Wrong Tag Pushed**:
1. If not yet released, delete tag quickly:
   ```bash
   git tag -d v1.2.3
   git push --delete origin v1.2.3
   ```
2. If already released, create corrected version with patch increment

## 📖 Quick Reference

### Tag Creation Commands
```bash
# Stable release
git tag v1.2.3 && git push origin v1.2.3

# Beta release  
git tag v1.2.3-beta.1 && git push origin v1.2.3-beta.1

# Using script (interactive)
./scripts/create-semver-tag.sh

# Using script (automated)
./scripts/create-semver-tag.sh --type stable --version 1.2.3 --non-interactive
```

### Version Increment Rules
- `1.0.0 → 2.0.0` (major - breaking changes)
- `1.0.0 → 1.1.0` (minor - new features)
- `1.0.0 → 1.0.1` (patch - bug fixes)

### Pre-release Progression
- `v1.2.3-alpha.1 → v1.2.3-alpha.2 → v1.2.3-beta.1 → v1.2.3-rc.1 → v1.2.3`

This semver tag-based system ensures consistent, reliable, and automated releases while maintaining full control over when and what gets released.
