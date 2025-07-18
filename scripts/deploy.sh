#!/bin/bash

# Daily Devotional App Deployment Script
# This script builds and deploys the Flutter web app to Firebase Hosting

set -e  # Exit on any error

echo "🚀 Starting deployment process..."

# Check if we're in the right directory
if [ ! -f "../pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the scripts/ directory"
    exit 1
fi

# Move to project root
cd ..

echo "📋 Checking Firebase configuration..."

# Check if Firebase options file exists
if [ ! -f "lib/firebase_options.dart" ]; then
    echo "❌ Error: Firebase configuration missing!"
    echo "Please copy lib/firebase_options.dart.template to lib/firebase_options.dart"
    echo "and add your Firebase configuration keys."
    exit 1
fi

# Check if Google Services file exists
if [ ! -f "android/app/google-services.json" ]; then
    echo "❌ Error: Android Google Services configuration missing!"
    echo "Please copy android/app/google-services.json.template to android/app/google-services.json"
    echo "and add your Firebase configuration."
    exit 1
fi

echo "🧹 Cleaning previous builds..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building web app for production..."
flutter build web --release

echo "🚀 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Deployment completed successfully!"
echo "🌐 Your app should be available at your Firebase hosting URL"