# Release Management Documentation

This document describes the comprehensive release management system for the `gh-pwsh-skills` CLI tool.

## Overview

The release system supports multiple release types with automated CI/CD pipelines and manual trigger capabilities:

- 🧪 **Beta Releases** - For testing new features
- 🚀 **Release Candidates** - Final testing before stable
- ✅ **Stable Releases** - Production-ready versions  
- 🔥 **Hotfix Releases** - Urgent bug fixes

## Release Workflow

### Automatic Releases

Releases are automatically triggered when:
- Code is pushed to `main`, `develop`, or `beta` branches
- Manual workflow dispatch is triggered

### Manual Releases

Use the manual release script for controlled releases:

```bash
# Interactive mode (recommended)
./scripts/manual-release.sh

# Non-interactive examples
./scripts/manual-release.sh --type beta --increment patch
./scripts/manual-release.sh --type stable --version 1.2.3 --dry-run
./scripts/manual-release.sh --type hotfix --increment patch --skip-tests
```

## Release Types

### 1. Beta Releases (`beta`)

**Purpose**: Testing new features and gathering feedback

**Characteristics**:
- Creates prerelease by default
- Includes timestamp and commit hash in version
- Uses `.goreleaser.beta.yml` configuration
- Version format: `v1.2.3-beta.20231106123456.abc1234`

**Installation**:
```bash
gh extension install sup3r7-fabio/gh-pwsh-skills@v1.2.3-beta.20231106123456.abc1234
```

### 2. Release Candidates (`release-candidate`)

**Purpose**: Final testing before stable release

**Characteristics**:
- Creates prerelease by default
- Custom RC suffix (e.g., rc.1, rc.2)
- Version format: `v1.2.3-rc.1`

**Installation**:
```bash
gh extension install sup3r7-fabio/gh-pwsh-skills@v1.2.3-rc.1
```

### 3. Stable Releases (`stable`)

**Purpose**: Production-ready releases for end users

**Characteristics**:
- Not a prerelease (unless explicitly set)
- Clean version numbers
- Uses main `.goreleaser.yml` configuration
- Version format: `v1.2.3`

**Installation**:
```bash
gh extension install sup3r7-fabio/gh-pwsh-skills
gh extension upgrade gh-pwsh-skills
```

### 4. Hotfix Releases (`hotfix`)

**Purpose**: Urgent bug fixes that can't wait for the next release cycle

**Characteristics**:
- Not a prerelease
- Can skip tests if needed (not recommended)
- Version format: `v1.2.3-hotfix` or incremented patch version

## Version Management

### Version Increment Strategies

1. **Auto Detection** (`auto`) - Default
   - Analyzes commit messages for conventional commits
   - `BREAKING CHANGE` or `feat!:`/`fix!:` → major version bump
   - `feat:` → minor version bump  
   - Other changes → patch version bump

2. **Manual Increment**
   - `major` - 1.0.0 → 2.0.0
   - `minor` - 1.0.0 → 1.1.0
   - `patch` - 1.0.0 → 1.0.1

3. **Custom Version**
   - Specify exact version (e.g., `1.2.3`)
   - Overrides increment strategy

### Version Examples

```bash
# Current version: v1.2.3

# Auto increment (based on commits)
--increment auto

# Manual increments
--increment major    # → v2.0.0
--increment minor    # → v1.3.0
--increment patch    # → v1.2.4

# Custom version
--version 2.1.0      # → v2.1.0

# Beta versions
--type beta --increment patch  # → v1.2.4-beta.20231106123456.abc1234
```

## Configuration Files

### Main GoReleaser (`.goreleaser.yml`)
- Used for stable and hotfix releases
- Production-ready configuration
- Standard archive naming

### Beta GoReleaser (`.goreleaser.beta.yml`)
- Used for beta and release candidate releases
- Beta-specific configuration
- Special archive naming with `_beta` suffix
- Enhanced changelog for beta releases

## Manual Release Script Options

### Basic Usage
```bash
./scripts/manual-release.sh [OPTIONS]
```

### Available Options

| Option | Description | Values |
|--------|-------------|---------|
| `-t, --type` | Release type | `beta`, `release-candidate`, `stable`, `hotfix` |
| `-i, --increment` | Version increment | `auto`, `major`, `minor`, `patch` |
| `-v, --version` | Custom version | Any valid version (e.g., `1.2.3`) |
| `-b, --beta-suffix` | Beta suffix | Custom suffix for beta/RC releases |
| `-p, --prerelease` | Prerelease flag | `true`, `false` |
| `-s, --skip-tests` | Skip tests | Flag (not recommended) |
| `-d, --dry-run` | Dry run mode | Flag (build but don't publish) |
| `-n, --non-interactive` | Non-interactive | Flag (no prompts) |
| `-h, --help` | Help | Show usage information |

### Example Commands

```bash
# Interactive release (recommended for first-time users)
./scripts/manual-release.sh

# Quick beta release
./scripts/manual-release.sh -t beta -i patch

# Stable release with custom version
./scripts/manual-release.sh -t stable -v 2.0.0

# Release candidate with dry run
./scripts/manual-release.sh -t release-candidate -i minor -d

# Emergency hotfix (skip tests)
./scripts/manual-release.sh -t hotfix -i patch -s

# Non-interactive stable release
./scripts/manual-release.sh -t stable -i minor -n
```

## GitHub Actions Workflow

### Workflow Triggers

1. **Push Events**
   - Branches: `main`, `develop`, `beta`
   - Ignores: `**.md`, `docs/**`

2. **Manual Dispatch** 
   - Via GitHub Actions UI
   - Via `gh` CLI
   - Via release scripts

### Workflow Inputs

| Input | Description | Required | Default | Type |
|-------|-------------|----------|---------|------|
| `release_type` | Release type | Yes | `beta` | choice |
| `version_increment` | Version increment | Yes | `auto` | choice |
| `custom_version` | Custom version | No | - | string |
| `beta_version` | Beta suffix | No | `beta` | string |
| `create_prerelease` | Create prerelease | No | `true` | boolean |
| `skip_tests` | Skip tests | No | `false` | boolean |
| `dry_run` | Dry run mode | No | `false` | boolean |

### Workflow Jobs

1. **Test Job**
   - Runs Go tests
   - Builds project
   - Can be skipped with `skip_tests`

2. **Release Job**
   - Generates version
   - Creates git tag
   - Runs GoReleaser
   - Handles dry runs

3. **Notify Job**
   - Provides release summary
   - Shows installation instructions
   - Reports any failures

## Installation and Usage

### For End Users

**Latest Stable**:
```bash
gh extension install sup3r7-fabio/gh-pwsh-skills
```

**Specific Version**:
```bash
gh extension install sup3r7-fabio/gh-pwsh-skills@v1.2.3
```

**Upgrade**:
```bash
gh extension upgrade gh-pwsh-skills
```

### For Beta Testers

**Latest Beta**:
```bash
# Check releases page for latest beta version
gh extension install sup3r7-fabio/gh-pwsh-skills@v1.2.3-beta.20231106123456.abc1234
```

## Best Practices

### Release Workflow

1. **Feature Development**
   ```
   develop branch → beta release → testing → feedback
   ```

2. **Release Preparation**
   ```
   main branch → release candidate → final testing → stable release
   ```

3. **Emergency Fixes**
   ```
   main branch → hotfix release (can skip some steps)
   ```

### Version Strategy

- Use **auto increment** for regular development
- Use **major** for breaking changes
- Use **minor** for new features
- Use **patch** for bug fixes
- Use **custom** for special releases (e.g., syncing with another system)

### Testing Strategy

- Always test beta releases before promoting to stable
- Use dry runs to verify release configuration
- Don't skip tests unless it's an emergency hotfix
- Test installation commands after each release

### Communication

- Tag beta testers for beta releases
- Announce stable releases to all users  
- Document breaking changes clearly
- Provide migration guides for major versions

## Troubleshooting

### Common Issues

1. **Workflow Fails on Version Generation**
   - Check git tags exist
   - Verify conventional commit format
   - Ensure custom version is valid

2. **GoReleaser Fails**
   - Verify `.goreleaser.yml` syntax
   - Check build environment
   - Ensure all required files exist

3. **Tag Already Exists**
   - Version conflicts with existing tag
   - Use different version or delete existing tag

4. **Permission Denied**
   - Check GitHub token permissions
   - Verify repository access
   - Ensure workflow has write permissions

### Debug Mode

Use dry run mode to test without publishing:
```bash
./scripts/manual-release.sh --dry-run --type stable --increment minor
```

### Manual Recovery

If a release fails partway through:

1. Check the GitHub Actions logs
2. Delete the created tag if needed: `git tag -d v1.2.3 && git push --delete origin v1.2.3`
3. Fix the issue and retry
4. Use dry run first to verify the fix

## Monitoring and Analytics

### Release Metrics

Monitor these metrics for release health:
- Release frequency
- Time between beta and stable
- Issue reports after releases
- Adoption rates of new versions

### Release Pages

- **All Releases**: https://github.com/sup3r7-fabio/gh-pwsh-skills/releases
- **Latest Stable**: https://github.com/sup3r7-fabio/gh-pwsh-skills/releases/latest
- **Actions**: https://github.com/sup3r7-fabio/gh-pwsh-skills/actions

---

## Quick Reference

### Create a Beta Release
```bash
./scripts/manual-release.sh --type beta --increment patch
```

### Create a Stable Release
```bash  
./scripts/manual-release.sh --type stable --increment minor
```

### Emergency Hotfix
```bash
./scripts/manual-release.sh --type hotfix --increment patch --skip-tests
```

### Test Release Configuration
```bash
./scripts/manual-release.sh --dry-run --type stable --version 2.0.0
```

For more help, run `./scripts/manual-release.sh --help` or open an issue in the repository.
