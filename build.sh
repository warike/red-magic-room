#!/bin/bash

cd "$(dirname "$0")"

echo "🔨 Building Red Magic Room..."

# Kill running instances
pkill -x RedMagicRoom 2>/dev/null

# Build release
swift build -c release
if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

# Create/update app bundle
mkdir -p dist/RedMagicRoom.app/Contents/MacOS
mkdir -p dist/RedMagicRoom.app/Contents/Resources

cp .build/release/RedMagicRoom dist/RedMagicRoom.app/Contents/MacOS/RedMagicRoom
cp RedMagicRoom/Info.plist dist/RedMagicRoom.app/Contents/
cp AppIcon.icns dist/RedMagicRoom.app/Contents/Resources/

# Create zip for sharing
cd dist
rm -f RedMagicRoom.zip
zip -r RedMagicRoom.zip RedMagicRoom.app
cd ..

echo "✅ Build complete!"
echo ""
echo "📦 App: dist/RedMagicRoom.app"
echo "📤 Share: dist/RedMagicRoom.zip"
echo ""

# Launch if --run flag passed
if [ "$1" == "--run" ]; then
    echo "🚀 Launching..."
    open dist/RedMagicRoom.app
fi
