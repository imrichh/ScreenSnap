# ScreenSnap

macOS menu bar app for quick screenshot clipboard copy.

## Git Workflow

Follow the `git-release-workflow` skill. Distribution mode: **App store** (source on GitHub with full branching).

- `main` = stable releases only (equivalent to `master` in the skill)
- `develop` = daily work
- `feature/*`, `fix/*` = short-lived branches off develop
- `release/*` = cut from develop when ready to ship

## Build

```bash
xcodebuild -project ScreenSnap.xcodeproj -scheme ScreenSnap -configuration Release -derivedDataPath release-build ONLY_ACTIVE_ARCH=NO
```

Release zip:
```bash
ditto -c -k --keepParent release-build/Build/Products/Release/ScreenSnap.app ScreenSnap.zip
```
