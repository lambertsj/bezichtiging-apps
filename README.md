# Bezichtiging

[![Basis Certified](https://basisapps.nl/badge.svg)](https://basisapps.nl)

Checklist-app voor woningbezichtigingen, voor iOS en Android. Meer info op [bezichtiging.app](https://bezichtiging.app).

Onderdeel van [BasisApps](https://basisapps.nl), het initiatief voor eerlijke apps die gewoon gratis horen te zijn: geen abonnementen, geen advertenties en geen tracking. In de app stores heet de app **Basis: Bezichtiging checklist**.

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

## Licentie

MIT, zie [LICENSE](LICENSE).
