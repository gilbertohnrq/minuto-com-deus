#!/bin/bash

# Daily Devotional App - Release Build Script
# This script builds the release APK with proper error handling

set -e  # Exit on any error

echo "🚀 Starting Daily Devotional App release build..."

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH."
    exit 1
fi

# Check if google-services.json exists
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  Warning: google-services.json not found in android/app/"
    echo "   Please follow the Firebase setup instructions in FIREBASE_SETUP.md"
    echo "   Continuing with template configuration..."
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation if needed
echo "🔧 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

# Build release APK
echo "📱 Building release APK..."
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📂 APK location: build/app/outputs/flutter-apk/app-release.apk"
    
    # Show APK size
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    echo "📏 APK size: $APK_SIZE"
    
    echo ""
    echo "🎉 Release build completed successfully!"
    echo "📱 Install with: flutter install --release"
else
    echo "❌ Build failed!"
    exit 1
fi 