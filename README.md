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


## IPA troubleshooting (important)

If your exported IPA is around **65 KB**, it is almost certainly invalid/incomplete.
Use `IPA_VALIDATION.md` for a full checklist and verification commands.

Key point: Apple iOS SDKs/frameworks (UIKit/SwiftUI/Foundation/etc.) are **not embedded** in IPA; iOS provides them at runtime.
Only your app binary, resources, and any required third-party embedded frameworks ship in the IPA.

## Real test logic (device)

NetProof now supports real HTTP-based throughput tests via `HTTPNetworkTestService` using your backend endpoints (`/download`, `/upload`, `/health`).
Set `AppConfig.useRealHTTPTests = true` and point `backendBaseURL` at a reachable host from iPhone.

### About Speedtest.net / Fast.com APIs

For MVP, this repo uses your own backend test endpoints. Third-party speed APIs may require licensing or have restrictive terms.
Use officially documented APIs and terms before integrating any external provider.

## No-server testing mode

If you do not have your own backend yet, set `AppConfig.provider = .publicFallback`.
This mode uses:
- Download: Cloudflare speed test file URL
- Upload: `https://httpbin.org/post`

This gives a practical, rough real-world test path on device while you bootstrap your own backend.

## Speedtest.net / Fast.com integration note

Do **not** MITM or scrape proprietary speed-test traffic. Use only official APIs/SDKs and terms.
This project currently avoids unauthorized integration and instead uses either:
1. your own backend (`.netProofBackend`), or
2. public fallback endpoints (`.publicFallback`) for development.

## Production architecture for remote device speed tests

If users install from App Store/TestFlight, the app still runs tests locally on-device, but against internet endpoints you control.

Recommended flow:
1. App requests `/config` to get nearest region endpoint + test parameters.
2. **Download test**: app downloads large objects (e.g., 25MB, 50MB) and measures time + interval throughput.
3. **Upload test**: app generates padded in-memory payloads (e.g., 4MB/8MB chunks) and uploads to `/upload`.
4. **Latency/Jitter**: app sends repeated small probes to `/health` before/during load.
5. **Bufferbloat**: compare idle latency vs. latency during sustained upload/download.
6. Persist all metrics and compute diagnosis + health score.

### Why this works without user-owned servers

You host `server/` once (Fly.io/Render/Railway/AWS), and every app instance tests against that managed endpoint.
No local server is required on user devices.

## Raspberry Pi 5 upload server image

A Pi 5 image pipeline is included under `pi-image/` plus workflow `.github/workflows/pi-image-build.yml`.

For your setup (`http://franksplex.com`, no TLS yet):
- run server in `UPLOAD_ONLY=true`
- set `ALLOWED_ORIGIN=http://franksplex.com`
- point app `AppConfig.provider = .netProofBackend` and `backendBaseURL` to your Pi endpoint

See `pi-image/README.md` for image build + flashing steps.
