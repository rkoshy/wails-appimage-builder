# Publishing Guide

This document outlines the steps to publish the `wails-appimage-builder` Docker image to Docker Hub and GitHub.

## Prerequisites

1. **Docker Hub Account** - Create account at https://hub.docker.com
2. **GitHub Account** - For source code repository
3. **Docker installed** - To build and push images

## Step 1: Create GitHub Repository

### Option A: Via GitHub Web Interface
1. Go to https://github.com/new
2. Repository name: `wails-appimage-builder`
3. Description: "Docker image for building Wails applications and packaging them as AppImages"
4. Public repository
5. Do NOT initialize with README (we already have one)
6. Click "Create repository"

### Option B: Via GitHub CLI
```bash
cd ~/repositories/opensource/docker-images/wails-appimage-builder
gh repo create wails-appimage-builder --public --source=. --remote=origin \
  --description="Docker image for building Wails applications and packaging them as AppImages"
```

## Step 2: Initialize Git Repository

```bash
cd ~/repositories/opensource/docker-images/wails-appimage-builder

# Initialize git
git init

# Add all files
git add Dockerfile README.md LICENSE .gitignore PUBLISHING.md

# Create initial commit
git commit -m "Initial commit: Wails AppImage builder Docker image

- Debian 12 (Bookworm) base for maximum compatibility
- Go 1.22.10 + Wails v2 + Node.js 20.x
- linuxdeploy for AppImage packaging
- mingw-w64 and NSIS for Windows cross-compilation
- Complete build and packaging toolchain"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin git@github.com:YOUR_USERNAME/wails-appimage-builder.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Set Up Docker Hub

### Create Docker Hub Repository
1. Go to https://hub.docker.com/repositories
2. Click "Create Repository"
3. Repository name: `wails-appimage-builder`
4. Description: "Docker image for building Wails applications and packaging them as AppImages"
5. Visibility: Public
6. Click "Create"

### Log in to Docker Hub
```bash
docker login
# Enter your Docker Hub username and password
```

## Step 4: Build and Tag the Image

```bash
cd ~/repositories/opensource/docker-images/wails-appimage-builder

# Build the image (replace YOUR_DOCKERHUB_USERNAME)
docker build -t YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:latest .

# Also tag with version
docker tag YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:latest \
  YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:1.0.0
```

## Step 5: Push to Docker Hub

```bash
# Push latest tag
docker push YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:latest

# Push version tag
docker push YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:1.0.0
```

## Step 6: Update README with Docker Hub Badge

Add this to the top of README.md (replace YOUR_DOCKERHUB_USERNAME):

```markdown
# Wails AppImage Builder

![Docker Pulls](https://img.shields.io/docker/pulls/YOUR_DOCKERHUB_USERNAME/wails-appimage-builder)
![Docker Image Size](https://img.shields.io/docker/image-size/YOUR_DOCKERHUB_USERNAME/wails-appimage-builder)
![Docker Image Version](https://img.shields.io/docker/v/YOUR_DOCKERHUB_USERNAME/wails-appimage-builder)

A Docker image for building [Wails](https://wails.io) applications and packaging them as AppImages for maximum Linux distribution compatibility.
```

## Step 7: Link Docker Hub to GitHub

1. Go to your Docker Hub repository page
2. Click on "Builds" tab
3. Click "Link to GitHub"
4. Select your `wails-appimage-builder` repository
5. Configure automated builds:
   - Source: `main` branch
   - Docker Tag: `latest`
   - Dockerfile location: `/Dockerfile`
6. Add another build rule:
   - Source: `/^v([0-9.]+)$/` (regex for version tags)
   - Docker Tag: `{\1}`
   - Dockerfile location: `/Dockerfile`

This will automatically build and push:
- `latest` tag when you push to `main` branch
- Version tags (e.g., `1.0.0`) when you create git tags like `v1.0.0`

## Step 8: Create GitHub Release (Optional but Recommended)

```bash
cd ~/repositories/opensource/docker-images/wails-appimage-builder

# Create and push a version tag
git tag -a v1.0.0 -m "Release v1.0.0

Initial release of Wails AppImage builder:
- Debian 12 base
- Go 1.22.10
- Wails v2
- Node.js 20.x
- linuxdeploy
- mingw-w64 + NSIS for Windows builds"

git push origin v1.0.0

# Create GitHub release via CLI
gh release create v1.0.0 --title "v1.0.0 - Initial Release" \
  --notes "Initial release of the Wails AppImage builder Docker image.

## What's Included
- Debian 12 (Bookworm) base
- Go 1.22.10
- Wails v2 CLI
- Node.js 20.x
- linuxdeploy for AppImage packaging
- mingw-w64 and NSIS for Windows cross-compilation

## Usage
\`\`\`bash
docker pull YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:1.0.0
\`\`\`

See README.md for complete usage instructions."
```

## Step 9: Verify Publication

### Verify Docker Hub
```bash
# Pull your published image
docker pull YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:latest

# Test it
docker run --rm YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:latest \
  bash -c "go version && wails version && linuxdeploy --version"
```

### Verify GitHub
- Visit https://github.com/YOUR_USERNAME/wails-appimage-builder
- Check that README renders correctly
- Check that files are all present

## Step 10: Promote Your Image

### Add Topics to GitHub
1. Go to your GitHub repository
2. Click "About" (gear icon)
3. Add topics: `docker`, `wails`, `appimage`, `golang`, `linux`, `packaging`, `debian`

### Update Docker Hub Description
1. Go to Docker Hub repository
2. Update the full description with the contents of README.md

### Share on Social Media / Forums
- Wails Discord: https://discord.gg/wails
- Reddit: r/golang, r/linux
- Dev.to / Hashnode blog post
- Twitter / X

## Maintenance

### Updating the Image

When you need to update (new Go version, Node.js, etc.):

```bash
cd ~/repositories/opensource/docker-images/wails-appimage-builder

# Make changes to Dockerfile
vim Dockerfile

# Commit changes
git add Dockerfile
git commit -m "Update Go to 1.23.x"
git push

# Create new version tag
git tag -a v1.1.0 -m "Update Go to 1.23.x"
git push origin v1.1.0

# If using automated builds, Docker Hub will auto-build
# Otherwise, manually build and push:
docker build -t YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:1.1.0 .
docker tag YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:1.1.0 \
  YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:latest
docker push YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:1.1.0
docker push YOUR_DOCKERHUB_USERNAME/wails-appimage-builder:latest
```

## Security Best Practices

1. **Never commit secrets** - Don't add AWS keys, passwords, etc. to the repository
2. **Pin versions** - Consider pinning Go/Node.js versions for reproducibility
3. **Security scanning** - Enable Docker Hub vulnerability scanning
4. **Regular updates** - Update base image and dependencies monthly

## License

This image is MIT licensed (see LICENSE file). Make sure this is acceptable for your use case.

## Questions?

- GitHub Issues: https://github.com/YOUR_USERNAME/wails-appimage-builder/issues
- Wails Discord: https://discord.gg/wails
