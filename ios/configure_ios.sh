#!/bin/bash

# iOS Configuration Script for ForCast App
# This script helps configure iOS settings for your Flutter app

echo "🚀 Configuring iOS settings for ForCast App..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Project paths
PROJECT_DIR="/Users/saqibjaved/private projects/forcastiq"
IOS_DIR="$PROJECT_DIR/ios"
RUNNER_DIR="$IOS_DIR/Runner"

echo -e "${BLUE}📱 iOS Configuration Checklist${NC}"
echo "================================="

# 1. Check if Xcode is installed
echo -e "${YELLOW}1. Checking Xcode installation...${NC}"
if command -v xcodebuild >/dev/null 2>&1; then
    XCODE_VERSION=$(xcodebuild -version | head -n1)
    echo -e "${GREEN}✅ Found: $XCODE_VERSION${NC}"
else
    echo -e "${RED}❌ Xcode not found. Please install Xcode from App Store.${NC}"
    exit 1
fi

# 2. Check iOS deployment target
echo -e "${YELLOW}2. Checking iOS deployment target...${NC}"
if grep -q "IPHONEOS_DEPLOYMENT_TARGET" "$IOS_DIR/Runner.xcodeproj/project.pbxproj"; then
    TARGET=$(grep "IPHONEOS_DEPLOYMENT_TARGET" "$IOS_DIR/Runner.xcodeproj/project.pbxproj" | head -1 | cut -d'=' -f2 | tr -d ' ";')
    echo -e "${GREEN}✅ iOS Deployment Target: $TARGET${NC}"

    # Recommend iOS 12.0 or higher for modern features
    if [[ $(echo "$TARGET >= 12.0" | bc -l 2>/dev/null || echo "0") == "1" ]]; then
        echo -e "${GREEN}✅ Deployment target is iOS 12.0+${NC}"
    else
        echo -e "${YELLOW}⚠️  Consider updating to iOS 12.0+ for better feature support${NC}"
    fi
else
    echo -e "${RED}❌ Could not find deployment target${NC}"
fi

# 3. Check Bundle ID
echo -e "${YELLOW}3. Checking Bundle Identifier...${NC}"
if grep -q "PRODUCT_BUNDLE_IDENTIFIER" "$IOS_DIR/Runner.xcodeproj/project.pbxproj"; then
    echo -e "${GREEN}✅ Bundle identifier is configured${NC}"
    echo -e "${BLUE}ℹ️  Remember to update bundle ID in Xcode for distribution${NC}"
else
    echo -e "${RED}❌ Bundle identifier not found${NC}"
fi

# 4. Check entitlements file
echo -e "${YELLOW}4. Checking entitlements file...${NC}"
if [ -f "$RUNNER_DIR/Runner.entitlements" ]; then
    echo -e "${GREEN}✅ Entitlements file exists${NC}"
else
    echo -e "${YELLOW}⚠️  Entitlements file not found${NC}"
fi

# 5. Check Info.plist permissions
echo -e "${YELLOW}5. Checking Info.plist permissions...${NC}"
PERMISSIONS=(
    "NSCameraUsageDescription"
    "NSPhotoLibraryUsageDescription"
    "NSPhotoLibraryAddUsageDescription"
    "NSLocalNetworkUsageDescription"
    "NSUserTrackingUsageDescription"
    "NSFaceIDUsageDescription"
)

for permission in "${PERMISSIONS[@]}"; do
    if grep -q "$permission" "$RUNNER_DIR/Info.plist"; then
        echo -e "${GREEN}✅ $permission configured${NC}"
    else
        echo -e "${RED}❌ $permission missing${NC}"
    fi
done

# 6. App Icon check
echo -e "${YELLOW}6. Checking App Icon...${NC}"
ICON_DIR="$RUNNER_DIR/Assets.xcassets/AppIcon.appiconset"
if [ -d "$ICON_DIR" ]; then
    ICON_COUNT=$(find "$ICON_DIR" -name "*.png" | wc -l)
    if [ $ICON_COUNT -gt 0 ]; then
        echo -e "${GREEN}✅ App icons found ($ICON_COUNT files)${NC}"
    else
        echo -e "${YELLOW}⚠️  No app icon images found${NC}"
        echo -e "${BLUE}ℹ️  Add app icons to $ICON_DIR${NC}"
    fi
else
    echo -e "${RED}❌ App icon directory not found${NC}"
fi

# 7. Launch Screen check
echo -e "${YELLOW}7. Checking Launch Screen...${NC}"
if [ -f "$RUNNER_DIR/Base.lproj/LaunchScreen.storyboard" ]; then
    echo -e "${GREEN}✅ Launch screen configured${NC}"
else
    echo -e "${RED}❌ Launch screen not found${NC}"
fi

# 8. Notification setup
echo -e "${YELLOW}8. Checking notification setup...${NC}"
if grep -q "UNUserNotificationCenter" "$RUNNER_DIR/AppDelegate.swift"; then
    echo -e "${GREEN}✅ Notification handling configured in AppDelegate${NC}"
else
    echo -e "${RED}❌ Notification handling not configured${NC}"
fi

# 9. Check Flutter iOS version
echo -e "${YELLOW}9. Checking Flutter iOS configuration...${NC}"
cd "$PROJECT_DIR"
if flutter doctor --android-licenses >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Flutter is properly configured${NC}"
else
    echo -e "${YELLOW}⚠️  Run 'flutter doctor' to check for issues${NC}"
fi

echo ""
echo -e "${BLUE}📋 Next Steps for iOS Configuration:${NC}"
echo "======================================"
echo ""
echo -e "${YELLOW}In Xcode:${NC}"
echo "1. Open ios/Runner.xcworkspace (NOT .xcodeproj)"
echo "2. Select Runner target → Signing & Capabilities"
echo "3. Add your Apple Developer Team"
echo "4. Enable capabilities:"
echo "   - Push Notifications"
echo "   - Background Modes (Background fetch, Remote notifications)"
echo "   - Associated Domains (for deep links)"
echo "   - Sign in with Apple"
echo "   - App Groups (if needed)"
echo ""
echo -e "${YELLOW}For App Store submission:${NC}"
echo "1. Update bundle identifier to your unique ID"
echo "2. Add app icons in all required sizes"
echo "3. Configure provisioning profiles"
echo "4. Set up App Store Connect listing"
echo "5. Add privacy policy URL"
echo ""
echo -e "${YELLOW}For testing:${NC}"
echo "1. Run: flutter build ios"
echo "2. Test on physical iOS device"
echo "3. Test push notifications"
echo "4. Test deep linking"
echo ""
echo -e "${GREEN}🎉 iOS configuration script completed!${NC}"