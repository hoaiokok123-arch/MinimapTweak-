#!/bin/bash

# Script to build locally before pushing
# Usage: ./scripts/build.sh

set -e

echo "========================================="
echo "🔧 Building Minimap Tweak"
echo "========================================="

# Check if Theos is installed
if [ ! -d "$THEOS" ]; then
    echo "❌ THEOS not found. Installing..."
    git clone --recursive https://github.com/theos/theos.git ~/theos
    export THEOS=~/theos
    echo "✅ THEOS installed"
fi

# Download iOS SDK if not present
if [ ! -d "$THEOS/sdks/iPhoneOS14.5.sdk" ]; then
    echo "📱 Downloading iOS SDK..."
    mkdir -p $THEOS/sdks
    curl -L -o $THEOS/sdks/iPhoneOS14.5.sdk.zip https://github.com/theos/sdks/raw/master/iPhoneOS14.5.sdk.zip
    cd $THEOS/sdks && unzip -o iPhoneOS14.5.sdk.zip
    echo "✅ iOS SDK installed"
fi

# Install ldid
if [ ! -f "$THEOS/bin/ldid" ]; then
    echo "🔑 Installing ldid..."
    curl -L -o $THEOS/bin/ldid https://github.com/ProcursusTeam/ldid/releases/download/v2.1.5-procursus-2/ldid
    chmod +x $THEOS/bin/ldid
    echo "✅ ldid installed"
fi

# Clean and build
echo "🏗️ Building..."
make clean
make package

echo "========================================="
echo "✅ Build successful!"
echo "📁 Output: packages/ and .theos/obj/debug/"
echo "========================================="
ls -la packages/
ls -la .theos/obj/debug/
