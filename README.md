# SwiftLabStreamingLayerFramework

Swift wrapper for LSL C library.


TODO 2026-02-11 - Building for iOS - `Apps/SwiftLabStreamingLayerFramework/build_liblsl_ios.sh`
```bash
./Apps/SwiftLabStreamingLayerFramework/build_liblsl_ios.sh

➜  labstreaminglayer git:(master) ✗ xcodebuild -create-xcframework \
           -library /Users/pho/libs/labstreaminglayer/Apps/SwiftLabStreamingLayerFramework/ios_libs/device/lib/liblsl.a \
           -library /Users/pho/libs/labstreaminglayer/Apps/SwiftLabStreamingLayerFramework/ios_libs/simulator/lib/liblsl.a \
           -output SwiftLabStreamingLayerFramework.xcframework
xcframework successfully written out to: /Users/pho/libs/labstreaminglayer/SwiftLabStreamingLayerFramework.xcframework
```