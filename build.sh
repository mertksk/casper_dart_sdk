#!/bin/bash
echo "🔨 Building Casper Dart SDK..."

# Run tests
echo "🧪 Running tests..."
dart test test/condor_compatibility_test.dart

# Run example
echo "🚀 Running example..."
dart example/condor_working_example.dart

echo "✅ Build completed!"
