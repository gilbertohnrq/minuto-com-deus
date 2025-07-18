#!/bin/bash

# Build and Release Script for Daily Devotional App
# This script automatically increments version, builds APK, and distributes via Firebase App Distribution

set -e  # Exit on any error

echo "🚀 Starting automated build and release process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Function to increment version
increment_version() {
    local version_type=$1
    local current_version=$(grep "version:" pubspec.yaml | sed 's/version: //' | tr -d ' ')
    local version_name=$(echo $current_version | cut -d'+' -f1)
    local build_number=$(echo $current_version | cut -d'+' -f2)
    
    # Split version name into major.minor.patch
    IFS='.' read -ra VERSION_PARTS <<< "$version_name"
    local major=${VERSION_PARTS[0]}
    local minor=${VERSION_PARTS[1]}
    local patch=${VERSION_PARTS[2]}
    
    # Increment based on type
    case $version_type in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
        *)
            print_error "Invalid version type. Use: major, minor, or patch"
            exit 1
            ;;
    esac
    
    # Always increment build number
    build_number=$((build_number + 1))
    
    local new_version="${major}.${minor}.${patch}+${build_number}"
    
    print_status "Current version: $current_version"
    print_status "New version: $new_version"
    
    # Update pubspec.yaml
    sed -i.bak "s/version: $current_version/version: $new_version/" pubspec.yaml
    rm pubspec.yaml.bak
    
    print_success "Version updated to $new_version"
    echo $new_version
}

# Function to build APK
build_apk() {
    print_status "Cleaning project..."
    flutter clean
    
    print_status "Getting dependencies..."
    flutter pub get
    
    print_status "Building APK..."
    flutter build apk --release
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        print_success "APK build completed successfully"
        return 0
    else
        print_error "APK build failed"
        return 1
    fi
}

# Function to distribute via Firebase App Distribution
distribute_apk() {
    local version=$1
    local release_notes=$2
    
    print_status "Distributing APK via Firebase App Distribution..."
    
    # Check if Firebase CLI is available
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI not found. Please install it first."
        return 1
    fi
    
    # Distribute the APK
    firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
        --app 1:733461658307:android:7bcbec2e0928eb28884076 \
        --groups "testers" \
        --release-notes "$release_notes"
    
    print_success "APK distributed successfully"
}

# Function to commit and tag version
commit_version() {
    local version=$1
    
    print_status "Committing version changes..."
    
    # Check if git is available and we're in a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_warning "Not a git repository. Skipping version commit."
        return 0
    fi
    
    # Add pubspec.yaml changes
    git add pubspec.yaml
    git commit -m "chore: bump version to $version"
    
    # Create tag
    git tag "v$version"
    
    print_success "Version committed and tagged as v$version"
    
    # Ask if user wants to push
    read -p "Do you want to push changes to remote? (y/N): " push_confirm
    if [[ $push_confirm =~ ^[Yy]$ ]]; then
        git push origin main
        git push origin "v$version"
        print_success "Changes pushed to remote repository"
    fi
}

# Main execution
main() {
    local version_type=${1:-"patch"}
    local release_notes=${2:-"Automatic release from build script"}
    
    print_status "Starting build process with version type: $version_type"
    
    # Increment version
    new_version=$(increment_version $version_type)
    
    # Build APK
    if build_apk; then
        # Distribute APK
        if distribute_apk "$new_version" "$release_notes - Version: $new_version"; then
            # Commit version changes
            commit_version "$new_version"
            print_success "🎉 Build and release process completed successfully!"
            print_success "Version: $new_version"
            print_success "APK distributed to Firebase App Distribution"
        else
            print_error "Distribution failed"
            exit 1
        fi
    else
        print_error "Build failed"
        exit 1
    fi
}

# Help function
show_help() {
    echo "Usage: $0 [VERSION_TYPE] [RELEASE_NOTES]"
    echo ""
    echo "VERSION_TYPE:"
    echo "  patch   - Increment patch version (default)"
    echo "  minor   - Increment minor version"
    echo "  major   - Increment major version"
    echo ""
    echo "RELEASE_NOTES:"
    echo "  Optional release notes for the distribution"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Increment patch version"
    echo "  $0 minor                             # Increment minor version"
    echo "  $0 patch \"Bug fixes and improvements\"  # With custom release notes"
}

# Check for help flag
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Run main function
main "$@"
