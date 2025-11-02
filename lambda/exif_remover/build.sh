#!/bin/bash

# Build Lambda deployment package with dependencies
# This script creates a zip file with the Lambda code and all dependencies
# Uses Docker with AWS Lambda Python base image to ensure Linux compatibility

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
OUTPUT_ZIP="${SCRIPT_DIR}/lambda_function.zip"

echo "Building Lambda deployment package..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker to build Lambda packages with native dependencies."
    echo "Alternatively, use build-no-docker.sh if you don't need compiled dependencies."
    exit 1
fi

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

# Copy Lambda function code
echo "Copying Lambda function code..."
cp "${SCRIPT_DIR}/lambda_function.py" "$BUILD_DIR/"

# Install dependencies using Docker with AWS Lambda Python base image
if [ -f "${SCRIPT_DIR}/requirements.txt" ]; then
    echo "Installing dependencies using Docker (AWS Lambda Python 3.11 environment)..."
    docker run --rm \
        --platform linux/amd64 \
        --entrypoint pip \
        -v "${SCRIPT_DIR}/requirements.txt:/tmp/requirements.txt" \
        -v "${BUILD_DIR}:/tmp/build" \
        public.ecr.aws/lambda/python:3.11 \
        install -r /tmp/requirements.txt -t /tmp/build --no-cache-dir
else
    echo "No requirements.txt found, skipping dependency installation"
fi

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
