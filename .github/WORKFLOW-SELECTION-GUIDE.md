# 🚀 GitHub Actions Workflow Selection Guide

## Overview

This repository has multiple release workflows to support different release strategies. **Only use ONE workflow at a time** to avoid conflicts.

## 🔄 Available Workflows

### 1. **Manual Release Workflow** (Recommended for most use cases)
**File**: `.github/workflows/beta-release.yml`
**Trigger**: Manual dispatch only
**Use when**: You want full control over releases

```bash
# Trigger via GitHub UI or CLI
gh workflow run beta-release.yml \
  --field release_type=stable \
  --field version=v1.0.0 \
  --field dry_run=false
```

**Features**:
- ✅ Manual control
- ✅ Dry-run support  
- ✅ Multiple release types (stable, beta, alpha, rc, dev, nightly)
- ✅ No tag conflicts
- ✅ Comprehensive validation

---

### 2. **Tag-Based Release Workflow** (For automated releases)
**File**: `.github/workflows/release-on-tag.yml`
**Trigger**: Semver tags
**Use when**: You want releases triggered automatically by tags

```bash
# Create and push a semver tag
git tag v1.0.0
git push origin v1.0.0

# Or pre-release
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1
```

**Supported tag patterns**:
- `v1.0.0` (stable)
- `v1.0.0-alpha.N` (alpha)
- `v1.0.0-beta.N` (beta)
- `v1.0.0-rc.N` (release candidate)
- `v1.0.0-dev.N` (development)
- `v1.0.0-nightly.N` (nightly)

---

### 3. **Strict Semver Release** (Production environments)
**File**: `.github/workflows/strict-semver-release.yml`
**Trigger**: Only strict semver tags
**Use when**: You need strict semver compliance

```bash
# Only these patterns work:
git tag v1.0.0           # Stable
git tag v1.0.0-alpha.1   # Alpha  
git tag v1.0.0-beta.1    # Beta
git tag v1.0.0-rc.1      # Release candidate
```

**Restrictions**:
- ❌ No dev/nightly builds
- ❌ No custom prerelease types
- ✅ Strict version progression validation

---

### 4. **Flexible Semver Release** (Development workflows)
**File**: `.github/workflows/flexible-semver-release.yml`
**Trigger**: Extended semver patterns
**Use when**: You need additional prerelease types

```bash
# Extended patterns supported:
git tag v1.0.0-dev.123     # Development
git tag v1.0.0-nightly.456 # Nightly  
git tag v1.0.0-hotfix.1    # Hotfix
git tag v1.0.0-build.123   # Build
```

**Additional types**:
- `hotfix` (urgent fixes - not prerelease)
- `build` (specific builds)
- All strict semver patterns

---

### 5. **Legacy Release** (Disabled)
**File**: `.github/workflows/release.yml` 
**Status**: ⚠️ Disabled to prevent conflicts
**Use**: Only if forced via `force_legacy=true`

---

## 🎯 Choosing the Right Workflow

### For Most Projects (Recommended)
```
Use: beta-release.yml (Manual Release)
Why: Full control, no conflicts, supports all release types
```

### For Automated CI/CD
```
Use: release-on-tag.yml (Tag-Based)  
Why: Automatic releases on tag push, good semver support
```

### For Enterprise/Production
```
Use: strict-semver-release.yml (Strict Semver)
Why: Enforces semver standards, production-grade validation
```

### For Active Development
```
Use: flexible-semver-release.yml (Flexible)
Why: Supports dev/nightly builds, extended prerelease types
```

---

## 🚨 Avoiding Conflicts

### ❌ Don't Do This (Causes Conflicts)
- Having multiple tag-triggered workflows enabled
- Using `release.yml` alongside semver workflows
- Creating tags that match multiple workflow patterns

### ✅ Do This Instead
- Choose ONE primary workflow
- Disable others by renaming files (add `.disabled` extension)
- Use manual workflows when you need different release types

---

## 🔧 Disabling Conflicting Workflows

### Option 1: Rename Files (Recommended)
```bash
# Disable workflows by renaming
mv .github/workflows/release.yml .github/workflows/release.yml.disabled
mv .github/workflows/strict-semver-release.yml .github/workflows/strict-semver-release.yml.disabled
```

### Option 2: Add Condition to Disable
Add to the workflow file:
```yaml
on:
  workflow_dispatch:  # Only manual trigger
  # Remove: push: tags: patterns
```

### Option 3: Delete Unused Workflows
```bash
# Remove workflows you don't need
rm .github/workflows/release.yml
rm .github/workflows/strict-semver-release.yml
```

---

## 🏷️ Tag Naming Best Practices

### Stable Releases
```bash
v1.0.0, v1.0.1, v1.1.0, v2.0.0
```

### Pre-releases
```bash
v1.0.0-alpha.1, v1.0.0-alpha.2
v1.0.0-beta.1, v1.0.0-beta.2  
v1.0.0-rc.1, v1.0.0-rc.2
```

### Development (if using flexible workflow)
```bash
v1.0.0-dev.20231106
v1.0.0-nightly.123
v1.0.0-hotfix.1
```

---

## 📋 Current Recommendations

Based on your setup, I recommend:

1. **Primary**: Use `beta-release.yml` for manual releases
2. **Secondary**: Use `release-on-tag.yml` for tag-based releases  
3. **Disable**: `release.yml` (already disabled)
4. **Optional**: Keep `strict-semver-release.yml` OR `flexible-semver-release.yml` (not both)

This gives you both manual control and automated releases without conflicts.
