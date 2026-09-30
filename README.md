# Bezichtiging

Checklist-app voor woningbezichtigingen, voor iOS en Android. Meer info op [bezichtiging.app](https://bezichtiging.app).

```
ios/       SwiftUI-app (open ios/Bezichtiging.xcodeproj in Xcode)
android/   Jetpack Compose-app (open android/ in Android Studio)
```

## Android release-build

De signing-gegevens staan bewust niet in de repo. Zet ze in `~/.gradle/gradle.properties`:

```
RELEASE_STORE_FILE=/pad/naar/keystore.jks
RELEASE_STORE_PASSWORD=...
RELEASE_KEY_ALIAS=...
RELEASE_KEY_PASSWORD=...
```
