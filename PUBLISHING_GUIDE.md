# Publishing Guide - Making FLT SDK Available on Web

This guide will help you publish your FLT SDK to GitHub so other developers can use it in their Flutter projects.

## Step 1: Create a GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the "+" icon in the top right corner
3. Select "New repository"
4. Name it `flt_sdk` (or your preferred name)
5. Choose Public or Private (Public allows anyone to use it)
6. **DO NOT** initialize with README, .gitignore, or license (we already have these)
7. Click "Create repository"

## Step 2: Push Your Code to GitHub

After creating the repository, GitHub will show you commands. Use these commands in your terminal:

```bash
# Add all files to git
git add .

# Commit the files
git commit -m "Initial commit: FLT SDK v1.0.0"

# Add the remote repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/flt_sdk.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Update README with Your Repository URL

After pushing, update the README.md file to replace `YOUR_USERNAME` with your actual GitHub username in the installation instructions.

## Step 4: Create a Release (Optional but Recommended)

1. Go to your repository on GitHub
2. Click on "Releases" → "Create a new release"
3. Tag version: `v1.0.0`
4. Release title: `FLT SDK v1.0.0`
5. Description: Initial release of FLT SDK
6. Click "Publish release"

## How Developers Will Use Your SDK

Once published, developers can add your SDK to their `pubspec.yaml`:

```yaml
dependencies:
  flt_sdk:
    git:
      url: https://github.com/YOUR_USERNAME/flt_sdk.git
      ref: main  # or use a specific tag like v1.0.0
```

Then they run:
```bash
flutter pub get
```

## Using Specific Versions

If you create releases with tags (like v1.0.0, v1.0.1, etc.), developers can pin to specific versions:

```yaml
dependencies:
  flt_sdk:
    git:
      url: https://github.com/YOUR_USERNAME/flt_sdk.git
      ref: v1.0.0  # specific version tag
```

## Updating the SDK

When you make updates:

```bash
# Make your changes
git add .
git commit -m "Description of changes"
git push origin main

# If you want to create a new version
git tag v1.0.1
git push origin v1.0.1
```

## Alternative: Using SSH URL

If developers have SSH access to your repository:

```yaml
dependencies:
  flt_sdk:
    git:
      url: git@github.com:YOUR_USERNAME/flt_sdk.git
      ref: main
```

## Notes

- Make sure your repository is **Public** if you want anyone to use it
- Keep the repository well-documented
- Use semantic versioning (v1.0.0, v1.0.1, v1.1.0, etc.)
- Update CHANGELOG.md when you make changes

