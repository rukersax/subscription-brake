# Subscription Brake - Frontend (Flutter + Riverpod)

## Architecture Overview
- **State Management**: `flutter_riverpod` (StateNotifierProvider, Provider)
- **Local Secure Storage**: `flutter_secure_storage` (AES encrypted on-device credentials)
- **Theme**: Material 3 with financial guard dog navy & emerald accents
- **Development Mode**: `AppConfig.developmentMode = true` mocks live API responses without consuming network quotas.

## Run Application
```bash
flutter pub get
flutter run
```
