# iOS Build Notes

Project ini dikembangkan di Windows dengan preview Chrome/Web.

## Status Saat Ini

- Development utama: Windows + Chrome
- Target final: iOS
- Build iOS lokal di Windows: tidak bisa
- Build iOS akan dilakukan via:
  - GitHub Actions macOS
  - Codemagic
  - Mac/Xcode jika tersedia nanti

## Build Web / Local Preview

```powershell
flutter analyze
flutter test
flutter run -d chrome