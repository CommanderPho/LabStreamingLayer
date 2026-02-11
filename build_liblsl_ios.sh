#!/bin/bash

# Build script for liblsl iOS static library
# This script builds liblsl for both iOS device (arm64) and iOS simulator (x86_64 + arm64)
# Usage: ./Apps/SwiftLabStreamingLayerFramework/build_liblsl_ios.sh (from workspace root)
#    or: ./build_liblsl_ios.sh (from Apps/SwiftLabStreamingLayerFramework directory)

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configuration
LIBLSL_SOURCE="$SCRIPT_DIR/../../LSL/liblsl"
BUILD_DIR="$SCRIPT_DIR/build_ios"
INSTALL_DIR="$SCRIPT_DIR/ios_libs"
IOS_DEPLOYMENT_TARGET="13.0"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building liblsl for iOS...${NC}"

# Verify source directory exists
if [ ! -d "$LIBLSL_SOURCE" ]; then
    echo -e "${RED}Error: liblsl source directory not found at: $LIBLSL_SOURCE${NC}"
    echo "Please ensure the LSL/liblsl directory exists in your workspace."
    exit 1
fi

echo "Using liblsl source: $LIBLSL_SOURCE"

# Clean previous builds
if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning previous build directory..."
    rm -rf "$BUILD_DIR"
fi

if [ -d "$INSTALL_DIR" ]; then
    echo "Cleaning previous install directory..."
    rm -rf "$INSTALL_DIR"
fi

# Create build directories
mkdir -p "$BUILD_DIR/device"
mkdir -p "$BUILD_DIR/simulator"
mkdir -p "$INSTALL_DIR"

# Build for iOS Device (arm64)
echo -e "${GREEN}Building for iOS Device (arm64)...${NC}"
cd "$BUILD_DIR/device"

cmake -G Xcode \
      -DCMAKE_SYSTEM_NAME=iOS \
      -DCMAKE_OSX_ARCHITECTURES=arm64 \
      -DCMAKE_OSX_DEPLOYMENT_TARGET="$IOS_DEPLOYMENT_TARGET" \
      -DCMAKE_OSX_SYSROOT=iphoneos \
      -DLSL_BUILD_STATIC=ON \
      -DLSL_BUILD_EXAMPLES=OFF \
      -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO \
      -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO \
      -DCMAKE_INSTALL_PREFIX="../../$INSTALL_DIR/device" \
      "$LIBLSL_SOURCE"

cmake --build . --config Release --target lsl

# Manually copy the library to avoid install issues
echo "Installing library..."
mkdir -p "$INSTALL_DIR/device/lib"
mkdir -p "$INSTALL_DIR/device/include"
cp Release-iphoneos/liblsl.a "$INSTALL_DIR/device/lib/"
cp -r "$LIBLSL_SOURCE/include/"* "$INSTALL_DIR/device/include/"

cd "$SCRIPT_DIR"

# Build for iOS Simulator (x86_64 + arm64)
echo -e "${GREEN}Building for iOS Simulator (x86_64 + arm64)...${NC}"
cd "$BUILD_DIR/simulator"

cmake -G Xcode \
      -DCMAKE_SYSTEM_NAME=iOS \
      -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
      -DCMAKE_OSX_DEPLOYMENT_TARGET="$IOS_DEPLOYMENT_TARGET" \
      -DCMAKE_OSX_SYSROOT=iphonesimulator \
      -DLSL_BUILD_STATIC=ON \
      -DLSL_BUILD_EXAMPLES=OFF \
      -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO \
      -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO \
      -DCMAKE_INSTALL_PREFIX="../../$INSTALL_DIR/simulator" \
      "$LIBLSL_SOURCE"

cmake --build . --config Release --target lsl

# Manually copy the library to avoid install issues
echo "Installing library..."
mkdir -p "$INSTALL_DIR/simulator/lib"
mkdir -p "$INSTALL_DIR/simulator/include"
cp Release-iphonesimulator/liblsl.a "$INSTALL_DIR/simulator/lib/"
cp -r "$LIBLSL_SOURCE/include/"* "$INSTALL_DIR/simulator/include/"

cd "$SCRIPT_DIR"

echo -e "${GREEN}Build complete!${NC}"
echo ""
echo "iOS Device library: $INSTALL_DIR/device/lib/liblsl.a"
echo "iOS Simulator library: $INSTALL_DIR/simulator/lib/liblsl.a"
echo ""
echo "To create an XCFramework for distribution, run:"
echo "xcodebuild -create-xcframework \\"
echo "           -library $INSTALL_DIR/device/lib/liblsl.a \\"
echo "           -library $INSTALL_DIR/simulator/lib/liblsl.a \\"
echo "           -output SwiftLabStreamingLayerFramework.xcframework"
