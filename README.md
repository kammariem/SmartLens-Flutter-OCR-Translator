# SmartLens — OCR & Language Translation Mobile App

SmartLens is a Flutter mobile application that combines Optical Character Recognition (OCR), language detection, and text translation.

The application allows users to capture text using their smartphone camera, extract it from images, and translate it into different languages.

## Features

- **Text Recognition:** Extract text from images using Google ML Kit OCR.
- **Language Detection:** Automatically identify the language of recognized text.
- **Text Translation:** Translate extracted text using on-device ML Kit translation models.
- **Firebase Authentication:** User registration and login.
- **Camera Integration:** Capture images directly from the application.
- **Cross-Platform Development:** Built with Flutter and Dart.

## Tech Stack

| Category | Technologies |
|---|---|
| Mobile Development | Flutter, Dart |
| Text Recognition | Google ML Kit OCR |
| Language Identification | ML Kit Language ID |
| Translation | ML Kit On-device Translation |
| Authentication | Firebase Authentication |
| Containerization | Docker |
| Android Build | Gradle, Kotlin |

## Docker Setup

The Android application can be compiled inside a Docker container without installing Flutter or the Android SDK locally.

### Prerequisites

- Docker Desktop
- Git

### Build Docker Image

```bash
docker build -t smartlens:1.0 .
```

### Generate Android APK

On Windows Command Prompt, from the project directory:

```cmd
docker run --rm -v "%cd%\build:/app/build" smartlens:1.0
```

The generated debug APK is available at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

**Note:** A valid Firebase configuration must be supplied before building if the Firebase configuration files are excluded from the repository.

The Android debug APK has been successfully compiled using Docker. Runtime functionality has not yet been fully validated on a physical device.

## Screenshots

Application screenshots will be added soon.

## Project Context

SmartLens is a collaborative academic project developed to explore mobile development and practical applications of Optical Character Recognition and language translation.

## License

See the LICENSE file for applicable licensing terms.
