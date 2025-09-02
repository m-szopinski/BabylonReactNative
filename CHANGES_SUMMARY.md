# BabylonReactNative CI and Build System Updates

## Summary of Changes

This document summarizes the changes made to remove Android/Windows support, add explicit macOS support, bump Node.js to version 20, restrict React Native versions to 0.69-0.71, and fix npm publish tag errors.

## 1. CI Workflow Updates

### Files Modified:
- `.github/workflows/build.yml`
- `.github/workflows/publish.yml` 
- `.github/workflows/test.yml`

### Changes:
- **Node.js Version**: Updated from Node 16 to Node 20 using `actions/setup-node@v4`
- **Platform Support**: Removed all Android and Windows build jobs
- **macOS Integration**: Added dedicated macOS library build alongside iOS builds
- **React Native Versions**: Restricted test matrix to only support 0.69, 0.70, and 0.71
- **Artifact Names**: Updated to use `iOSmacOS` instead of `iOSAndroid` naming
- **Publish Fix**: Fixed npm publish commands to use `--tag latest` flag and publish from correct directories

## 2. Gulpfile.js Build System Updates

### File Modified:
- `Package/gulpfile.js`

### Changes:
- **macOS Build Tasks**: Added new build functions:
  - `makeMacOSXCodeProj()` - Creates Xcode project for macOS
  - `makeMacOSXCodeProjRNTA()` - Creates Xcode project for macOS RNTA
  - `buildMacOSRelease()` - Builds macOS release configuration
  - `createMacOSFrameworks()` - Creates macOS frameworks/libraries
  - `buildMacOS` - Complete macOS build pipeline
  - `buildMacOSRNTA` - macOS RNTA build pipeline

- **Android/Windows Removal**: 
  - Commented out `buildAndroid()` and `buildAndroidRNTA()` functions
  - Removed all UWP/Windows build tasks and exports
  - Updated copy functions to work with iOS/macOS instead of iOS/Android

- **React Native Version Restriction**:
  - Updated `patchPackageVersion()` to only accept versions 0.69, 0.70, and 0.71
  - Added error message for unsupported versions
  - Updated peer dependency ranges to `>=0.69.0 <0.72.0`

- **Directory Structure**: 
  - Changed from `Assembled-iOSAndroid` to `Assembled-iOSmacOS`
  - Updated validation functions for new structure
  - Added macOS copy tasks alongside iOS copy tasks

## 3. Package.json Updates

### Files Modified:
- `Modules/@babylonjs/react-native/package.json`
- `Modules/@babylonjs/react-native-iosandroid/package.json`
- `Modules/@babylonjs/react-native-windows/package.json`

### Changes:
- **React Native Dependency**: Updated from `"*"` to `">=0.69.0 <0.72.0"` to restrict supported versions
- **Backward Compatibility**: Maintained existing functionality for supported versions

## 4. Infrastructure Improvements

### Files Modified:
- `.gitignore`

### Changes:
- Added exclusions for new build artifacts (`Package/Assembled*`, `macOS/Build/`)
- Added exclusions for npm package files (`*.tgz`)

## 5. macOS Platform Support

### Existing Support Validated:
- macOS source files already exist in `Modules/@babylonjs/react-native-iosandroid/macos/`
- macOS CMake configuration available in `Package/macos/CMakeLists.txt`
- macOS validation script exists (`validate-macos.js`)
- BRNPlayground already has `build:macos` npm script
- React Native macOS dependency already in BRNPlayground package.json

### New Integration:
- macOS builds now included in CI workflows
- macOS frameworks created and packaged alongside iOS builds
- macOS artifacts uploaded and published to npm

## Impact and Benefits

1. **Simplified Maintenance**: Removing Android and Windows reduces CI complexity and maintenance burden
2. **macOS Support**: Full macOS support now available with dedicated build pipeline
3. **Modern Node.js**: Node 20 provides better performance and security
4. **Focused React Native Support**: Supporting only 0.69-0.71 reduces compatibility matrix
5. **Reliable Publishing**: Fixed npm publish tag errors ensure correct package distribution

## Backward Compatibility

- **Breaking Change**: Android and Windows platforms no longer supported
- **Breaking Change**: React Native versions below 0.69 no longer supported  
- **Maintained**: iOS functionality preserved
- **Enhanced**: macOS now fully supported alongside iOS

## Testing Recommendations

1. Verify CI workflows complete successfully on all supported RN versions (0.69, 0.70, 0.71)
2. Test macOS build integration in real macOS development environment
3. Validate npm package publishing and installation
4. Confirm iOS functionality remains unaffected
5. Test BRNPlayground `build:macos` script functionality