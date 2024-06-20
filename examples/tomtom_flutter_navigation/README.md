# tomtom_flutter_navigation_example

Demonstrates how to use the tomtom_flutter_navigation plugin.

## How to run example

This example reads from the `JOURNEY_TOMTOM_SDK_SOURCE_URL` environment variable for the iOS cocoapods source URL, and `TOMTOM_API_KEY` from Dart's environment.

To run, you can:

```
export JOURNEY_TOMTOM_SDK_SOURCE_URL=https://dl.cloudsmith.io/your-repo-key-here/journey-technologies/tomtom_flutter/cocoapods/index.git
flutter run --dart-define TOMTOM_API_KEY=your-api-key-here
```