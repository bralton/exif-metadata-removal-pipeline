#!/bin/bash

# Build Lambda deployment package with dependencies
# This script creates a zip file with the Lambda code and all dependencies

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
OUTPUT_ZIP="${SCRIPT_DIR}/lambda_function.zip"

echo "Building Lambda deployment package..."

# Clean up previous build
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning up previous build..."
    rm -rf "$BUILD_DIR"
fi

if [ -f "$OUTPUT_ZIP" ]; then
    rm -f "$OUTPUT_ZIP"
fi

# Create build directory
mkdir -p "$BUILD_DIR"

# Install dependencies
if [ -f "${SCRIPT_DIR}/requirements.txt" ]; then
    echo "Installing dependencies..."
    pip3 install -r "${SCRIPT_DIR}/requirements.txt" -t "$BUILD_DIR" --quiet
else
    echo "No requirements.txt found, skipping dependency installation"
fi

# Copy Lambda function code
echo "Copying Lambda function code..."
cp "${SCRIPT_DIR}/lambda_function.py" "$BUILD_DIR/"

# Create zip file
echo "Creating deployment package..."
cd "$BUILD_DIR"
zip -r "$OUTPUT_ZIP" . -q

echo "Lambda deployment package created: $OUTPUT_ZIP"
echo "Package size: $(du -h "$OUTPUT_ZIP" | cut -f1)"

# Clean up build directory
cd "$SCRIPT_DIR"
rm -rf "$BUILD_DIR"

echo "Build complete!"
