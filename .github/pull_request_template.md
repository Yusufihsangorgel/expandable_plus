Issue: #<number>

Checklist, matching CI. Run in the repository root:

- [ ] `flutter pub get`
- [ ] `dart format --output=none --set-exit-if-changed .`
- [ ] `flutter analyze --fatal-infos`
- [ ] `flutter test --exclude-tags golden`
- [ ] `CHANGELOG.md` entry added
