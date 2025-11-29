# Regula Face SDK Setup Guide

## Important Notes

The `flutter_face_api` package requires proper configuration and the actual API methods may vary. Please refer to the official Regula Face SDK documentation for the exact API:

- [Regula Face SDK Documentation](https://docs.regulaforensics.com/develop/face-sdk/mobile/getting-started/installation/flutter/)
- [Package on pub.dev](https://pub.dev/packages/flutter_face_api)

## Setup Steps

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Android Configuration**
   - The `build.gradle.kts` has been updated with packaging configuration
   - Camera permissions are already in `AndroidManifest.xml`
   - **Note: This implementation is Android-only**

3. **API Usage**
   The controller uses the following Regula Face SDK methods (verify exact names in documentation):
   - `FaceSDK.init()` or `FaceSDK.initialize()` - Initialize the SDK (check main.dart)
   - `FaceSDK.presentFaceCaptureActivity()` - Capture live face
   - `FaceSDK.matchFaces()` - Compare two face images
   - `FaceSDK.detectFaces()` - Detect faces in an image
   
   **Important:** After running `flutter pub get`, verify the exact method names and signatures in the package documentation or by checking the package source.

## Troubleshooting

If you encounter API errors, please:
1. Check the actual API in the package documentation
2. Verify the package version matches the documentation
3. Ensure the SDK is properly initialized before use
4. Check that all required permissions are granted

## License

Note: Regula Face SDK may have licensing requirements. Please check the license terms before using in production.

