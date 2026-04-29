# NetProof

NetProof is an iOS 17+ SwiftUI app that helps users diagnose real-world internet quality issues (not only headline speed), track reliability over time, and export ISP-ready proof reports.

## Repo layout

- `NetProof/` — iOS app source scaffold.
- `server/` — Fastify backend for throughput and diagnostics endpoints.
- `.github/workflows/` — CI workflow for backend tests.

## iOS MVP features

- SwiftUI + MVVM structure with feature folders.
- SwiftData persistence for test history and plan profile.
- Mock + HTTP network test service architecture.
- Rule-based diagnosis engine in plain English.
- Internet Health Score calculator.
- PDF report generator service.
- StoreKit 2 purchase architecture with mock mode.

## Backend endpoints

- `GET /health`
- `GET /download?sizeMB=10`
- `POST /upload`
- `GET /config`

## Quick start (backend)

```bash
cd server
npm install
npm test
npm run dev
```

Default URL: `http://localhost:8080`

## iOS setup notes

1. Create an Xcode iOS App target named **NetProof** (iOS 17 minimum).
2. Add folders/files under `NetProof/` to the app target.
3. Add StoreKit product IDs:
   - `netproof_premium_monthly`
   - `netproof_premium_yearly`
   - `netproof_lifetime`
   - `netproof_single_report`
4. Configure backend URL in `AppConfig`.
5. For SSID access, only use `NEHotspotNetwork.fetchCurrent` when entitlement is available.

## Privacy principles

- No account required in MVP.
- No exact location collection required.
- No data sale.
- No private APIs.

## TestFlight prep checklist

- Add App Privacy labels in App Store Connect.
- Validate StoreKit products in sandbox.
- Replace mock network service with `HTTPNetworkTestService` for device runs.
- Confirm PDF export/paywall behavior.


## Unsigned iOS IPA release workflow

This repository includes `.github/workflows/ios-unsigned-ipa.yml` for automated unsigned Release IPA builds in GitHub Actions.

### What it automates

- Installs build tooling (`xcodegen`) on the macOS runner.
- Generates `NetProof.xcodeproj` from `project.yml` when the project file is missing.
- Resolves Swift package dependencies with `xcodebuild -resolvePackageDependencies`.
- Archives with signing disabled and packages an unsigned `.ipa`.
- Uploads the `.ipa` as an Actions artifact and (optionally) to a GitHub Release.

### Run it

1. Open **Actions** → **iOS Unsigned IPA** → **Run workflow**.
2. Provide:
   - `scheme` (default `NetProof`)
   - `configuration` (default `Release`)
   - `create_release` (default `true`: uploads `.ipa` to GitHub Releases)
3. Download from either:
   - the `unsigned-ipa` Actions artifact, or
   - the generated GitHub release asset.

### Notes

- Build is intentionally unsigned (`CODE_SIGNING_ALLOWED=NO`).
- This is designed for external/manual signing after download.
- No Apple signing certificates or API keys are stored in this repository.
