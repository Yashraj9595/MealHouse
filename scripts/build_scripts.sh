#!/bin/bash

# Build scripts for different environments

echo "🚀 Building Flutter App for different environments..."

# Development Build
echo "📱 Building for Development..."
flutter build apk --debug --dart-define=FLUTTER_ENV=development

# Staging Build
echo "🔨 Building for Staging..."
flutter build apk --release --dart-define=FLUTTER_ENV=staging

# Production Build
echo "🏭 Building for Production..."
flutter build apk --release --dart-define=FLUTTER_ENV=production

echo "✅ All builds completed!"
