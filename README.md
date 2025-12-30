# Wails AppImage Builder

![Docker Pulls](https://img.shields.io/docker/pulls/scorussolutions/wails-appimage-builder)
![Docker Image Size](https://img.shields.io/docker/image-size/scorussolutions/wails-appimage-builder)
![Docker Image Version](https://img.shields.io/docker/v/scorussolutions/wails-appimage-builder)

A Docker image for building [Wails](https://wails.io) applications and packaging them as AppImages for maximum Linux distribution compatibility.

**Docker Hub**: [scorussolutions/wails-appimage-builder](https://hub.docker.com/r/scorussolutions/wails-appimage-builder)

## Features

- **Debian 12 (Bookworm) base** - Ensures maximum forward compatibility across Linux distributions
- **Complete Wails v2 toolchain** - Go 1.25.5, Node.js, npm, Wails CLI
- **AppImage packaging** - linuxdeploy for creating portable Linux applications
- **Offline AppImage runtime** - Pre-downloaded runtime for packaging without internet access
- **Cross-platform support** - mingw-w64 and NSIS for Windows builds
- **All dependencies included** - libgtk-3, libwebkit2gtk-4.0, and all build tools

## What's Included

| Tool | Version | Purpose |
|------|---------|---------|
| Debian | 12 (Bookworm) | Base OS |
| Go | 1.25.5 | Backend compilation |
| Node.js | 20.x | Frontend builds |
| Wails | Latest v2 | Desktop app framework |
| linuxdeploy | Latest | AppImage creation |
| AppImage Runtime | Latest | Offline AppImage packaging |
| mingw-w64 | Latest | Windows cross-compilation |
| NSIS | Latest | Windows installer creation |
| WebKit2GTK | 4.0 | GUI rendering |

## Quick Start

### Pull from Docker Hub

```bash
docker pull scorussolutions/wails-appimage-builder:latest
```

### Or Build Locally

```bash
docker build -t scorussolutions/wails-appimage-builder:latest .
```

### Use the Image

**Build a Wails app:**
```bash
docker run --rm -v $(pwd):/workspace -w /workspace scorussolutions/wails-appimage-builder \
  bash -c "cd gui && wails build -platform linux/amd64"
```

**Build and package as AppImage:**
```bash
docker run --rm --privileged -v $(pwd):/workspace -w /workspace scorussolutions/wails-appimage-builder \
  bash -c "chmod +x build-appimage.sh && ./build-appimage.sh"
```

### Example AppImage Build Script

Here's a minimal `build-appimage.sh` for your Wails project:

```bash
#!/bin/bash
set -e

# Use the offline AppImage runtime included in the Docker image
export LDAI_RUNTIME_FILE=/opt/appimage-runtime/runtime-x86_64

VERSION=$(git describe --tags --always || echo "dev")

# Build the Wails binary
cd gui
wails build -platform linux/amd64 -o myapp-gui
cd ..

# Create AppDir structure
APPDIR="AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

# Copy binary
cp gui/build/bin/myapp-gui "$APPDIR/usr/bin/"

# Create desktop file
cat > "$APPDIR/usr/share/applications/myapp.desktop" << 'EOF'
[Desktop Entry]
Name=My App
Exec=myapp-gui
Icon=myapp
Type=Application
Categories=Utility;
EOF

# Create AppRun
cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
exec "${HERE}/usr/bin/myapp-gui" "$@"
EOF
chmod +x "$APPDIR/AppRun"

# Create AppImage
linuxdeploy --appdir "$APPDIR" --output appimage

# Rename with version
mv myapp-x86_64.AppImage "myapp-${VERSION}-x86_64.AppImage"
echo "AppImage created: myapp-${VERSION}-x86_64.AppImage"
```

## Why Debian 12?

Building on Debian 12 (Bookworm) ensures your AppImage will run on:
- Debian 11, 12, 13+
- Ubuntu 20.04, 22.04, 24.04+
- Fedora (recent versions)
- RHEL/CentOS 8+
- Arch Linux, Manjaro
- openSUSE Leap 15.4+
- And virtually any modern Linux distribution

AppImages built on older distros have better forward compatibility due to glibc versioning.

## Use Cases

1. **Local Development** - Build and test Wails apps in a consistent environment
2. **CI/CD Pipelines** - Reproducible builds in GitLab CI, GitHub Actions, etc.
3. **Cross-Platform Builds** - Build Linux and Windows binaries from the same image
4. **AppImage Distribution** - Package your app as a portable AppImage

## Requirements

- Docker installed and running
- For AppImage creation: `--privileged` flag (needed by FUSE)

## Directory Structure

When using this image, mount your project to `/workspace`:

```
/workspace/              # Your project root
├── gui/                 # Wails GUI directory
│   ├── frontend/        # Frontend code
│   └── wails.json       # Wails config
├── build-appimage.sh    # Your AppImage build script
└── ...
```

## Environment Variables

The following environment variables are pre-configured:

- `PATH=/usr/local/go/bin:/root/go/bin:$PATH`
- `GOPATH=/root/go`

For AppImage builds, you can use:
- `LDAI_RUNTIME_FILE=/opt/appimage-runtime/runtime-x86_64` - Use the pre-downloaded AppImage runtime for offline packaging

## Troubleshooting

**AppImage shows blank screen:**
- Ensure WebKit helper processes are bundled (see example script above)
- Set `WEBKIT_EXEC_PATH` in your AppRun script

**Frontend build fails:**
- Run `npm ci` in your frontend directory before building
- Check that `node_modules` is not in your .gitignore

**Permission errors:**
- Use `--privileged` flag for AppImage builds (required by FUSE)
- Ensure your build scripts are executable (`chmod +x`)

## Contributing

Contributions are welcome! Please open an issue or pull request.

## License

This Dockerfile is released under the MIT License.

## Related Projects

- [Wails](https://wails.io) - Build desktop apps using Go and web technologies
- [linuxdeploy](https://github.com/linuxdeploy/linuxdeploy) - AppImage creation tool
- [AppImage](https://appimage.org) - Portable Linux applications

## Support

For issues related to:
- **Wails**: See [Wails documentation](https://wails.io/docs/)
- **AppImage**: See [AppImage documentation](https://docs.appimage.org/)
- **This Docker image**: Open an issue in this repository
