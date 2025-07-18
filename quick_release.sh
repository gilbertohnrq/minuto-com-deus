#!/bin/bash

# Quick Release Script
# Usage: ./quick_release.sh [patch|minor|major] [release_notes]

VERSION_TYPE=${1:-"patch"}
RELEASE_NOTES=${2:-"Quick release"}

echo "🚀 Quick Release - Version Type: $VERSION_TYPE"
echo "📝 Release Notes: $RELEASE_NOTES"

# Make build script executable
chmod +x scripts/build_and_release.sh

# Run the build and release script
./scripts/build_and_release.sh "$VERSION_TYPE" "$RELEASE_NOTES"
