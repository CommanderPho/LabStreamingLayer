# iOS Setup Guide for SwiftLabStreamingLayerFramework

This guide explains how to integrate the SwiftLabStreamingLayerFramework Swift wrapper into an iOS project.

## Prerequisites

- Xcode 12.0 or later
- CMake 3.16 or later
- iOS deployment target 13.0 or later

## Step 1: Build liblsl for iOS

Run the build script to compile liblsl for iOS:

```bash
cd Apps/SwiftLabStreamingLayerFramework
./build_liblsl_ios.sh
```

This will create:
- `ios_libs/device/lib/liblsl.a` - Static library for iOS devices (arm64)
- `ios_libs/simulator/lib/liblsl.a` - Static library for iOS simulator (x86_64 + arm64)

## Step 2: Add Files to Xcode Project

1. **Add Swift source files** to your Xcode project:
   - `ChannelFormat.swift`
   - `Error.swift`
   - `Global.swift`
   - `Inlet.swift`
   - `Outlet.swift`
   - `Sample.swift`
   - `StreamInfo.swift`

2. **Add C headers** to your project:
   - `lsl_c.h`
   - `lsl_constants.h`

3. **Add static library**:
   - For device builds: `ios_libs/device/lib/liblsl.a`
   - For simulator builds: `ios_libs/simulator/lib/liblsl.a`
   - Or create an XCFramework (see Step 3)

## Step 3: Configure Bridging Header

1. In Xcode, go to your target's **Build Settings**
2. Search for "Objective-C Bridging Header"
3. Set the path to: `SwiftLabStreamingLayerFramework-Bridging-Header.h`
   - If you copied the files to your project, use the relative path from your project root
   - Example: `MyApp/SwiftLabStreamingLayerFramework/SwiftLabStreamingLayerFramework-Bridging-Header.h`

## Step 4: Link Static Library

### Option A: Link Separate Libraries (Recommended for Development)

1. In Xcode, select your target
2. Go to **Build Phases** → **Link Binary With Libraries**
3. Add `liblsl.a` from the appropriate directory:
   - For device: `ios_libs/device/lib/liblsl.a`
   - For simulator: `ios_libs/simulator/lib/liblsl.a`

Note: You'll need to switch the library when building for different targets.

### Option B: Create XCFramework (Recommended for Distribution)

Create a universal XCFramework that works for both device and simulator:

```bash
xcodebuild -create-xcframework \
           -library ios_libs/device/lib/liblsl.a \
           -library ios_libs/simulator/lib/liblsl.a \
           -output SwiftLabStreamingLayerFramework.xcframework
```

Then add `SwiftLabStreamingLayerFramework.xcframework` to your Xcode project.

## Step 5: Configure Info.plist (iOS 14+)

For iOS 14 and later, you must declare local network usage:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app uses LSL to send timestamped notes to research recording systems on your local network.</string>

<key>NSBonjourServices</key>
<array>
    <string>_lsl._tcp</string>
    <string>_lsl._udp</string>
</array>
```

## Step 6: Verify Installation

Create a simple test in your app:

```swift
import Foundation

// Test LSL integration
let streamInfo = StreamInfo(name: "TestStream", format: .string, id: "test-123")
let outlet = Outlet(streamInfo: streamInfo)

print("LSL outlet created successfully!")
print("Has consumers: \(outlet.hasConsumers)")
```

If this compiles and runs without errors, your integration is complete!

## Troubleshooting

### "Undefined symbols" errors

Make sure you've added `liblsl.a` to "Link Binary With Libraries" in Build Phases.

### "Use of undeclared type" errors

Check that the bridging header path is correct in Build Settings.

### "Module not found" errors

Ensure all Swift source files are added to your target's "Compile Sources" in Build Phases.

### Network permission issues

On iOS 14+, the app will prompt for local network access on first use. Make sure you've added the Info.plist entries.

## Additional Resources

- [LSL Documentation](https://labstreaminglayer.readthedocs.io/)
- [CMake iOS Toolchain](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#cross-compiling-for-ios)
- [Xcode Bridging Headers](https://developer.apple.com/documentation/swift/importing-objective-c-into-swift)
