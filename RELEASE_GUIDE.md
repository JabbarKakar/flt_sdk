# Release Guide

This guide explains how to create new releases and version tags for FLT SDK.

## Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features, backward compatible
- **PATCH** (0.0.1): Bug fixes, backward compatible

## Creating a Release

### Step 1: Update Version

Update the version in `pubspec.yaml`:

```yaml
version: 1.0.0  # Update this
```

### Step 2: Update CHANGELOG.md

Add your changes to `CHANGELOG.md`:

```markdown
## [1.0.1] - 2024-01-XX

### Fixed
- Fixed issue with message status updates
- Improved error handling

### Changed
- Updated default retry delay to 3 seconds
```

### Step 3: Commit Changes

```bash
git add .
git commit -m "Release v1.0.1"
git push origin main
```

### Step 4: Create Git Tag

```bash
# Create annotated tag
git tag -a v1.0.1 -m "Release v1.0.1"

# Push tag to GitHub
git push origin v1.0.1
```

### Step 5: Create GitHub Release

1. Go to your repository on GitHub
2. Click on "Releases" → "Draft a new release"
3. Select the tag you just created (e.g., `v1.0.1`)
4. Release title: `FLT SDK v1.0.1`
5. Description: Copy from CHANGELOG.md
6. Click "Publish release"

## Quick Release Script

You can use this script to automate the process:

```bash
#!/bin/bash
# release.sh

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./release.sh <version>"
  echo "Example: ./release.sh 1.0.1"
  exit 1
fi

# Update version in pubspec.yaml (manual step required)
echo "Please update version in pubspec.yaml to $VERSION"
read -p "Press enter when done..."

# Commit changes
git add .
git commit -m "Release v$VERSION"
git push origin main

# Create and push tag
git tag -a v$VERSION -m "Release v$VERSION"
git push origin v$VERSION

echo "Release v$VERSION created!"
echo "Now create a GitHub release at: https://github.com/JabbarKakar/flt_sdk/releases/new"
```

## Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md` with changes
- [ ] Test the SDK thoroughly
- [ ] Commit and push changes
- [ ] Create git tag
- [ ] Push tag to GitHub
- [ ] Create GitHub release
- [ ] Update documentation if needed

## Current Version

Current version: **v1.0.0**

See [CHANGELOG.md](CHANGELOG.md) for version history.

