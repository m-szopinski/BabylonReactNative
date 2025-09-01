# Babylon React Native iOS, macOS and Android Runtime

## Usage

This package contains iOS, macOS and Android dependencies for @babylonjs/react-native. See @babylonjs/react-native for usage.

### Platform Support

- **iOS**: Supports iOS 12.0+
- **macOS**: Supports macOS 10.15+ (Catalina and newer)
- **Android**: Supports Android API level as specified in the main project

### Dependencies

This package has several **peer dependencies**. If these dependencies are unmet, `npm install` will emit warnings. Be sure to add these dependencies to your project.

This package will not work without installing the `@babylonjs/react-native` peer dependency.
The `react-native-permissions` dependency is required for XR capabilities of Babylon.js.

### macOS Features

The macOS implementation includes all features available on iOS:
- Metal rendering pipeline
- Touch/Mouse event handling
- View management and snapshot functionality
- XR capabilities
- Anti-aliasing support
