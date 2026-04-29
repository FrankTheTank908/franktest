# Frank the Tank iOS test app

This repo is configured to auto-generate project config, build a signed IPA in GitHub Actions, and attach it to workflow artifacts + a GitHub Release.

## App behavior
- Full-screen "Frank the Tank" themed background.
- A **Push me** button.
- Tapping button shows popup: **Yay!**

## What is auto-generated
- Random bundle id by default during CI build (`com.autogen.<random>`).
- `Config/Generated.xcconfig` via `scripts/generate-config.sh`.
- Xcode project from `project.yml` using XcodeGen.

## Required secrets (for signed IPA)
- `APPLE_TEAM_ID`
- `BUILD_CERTIFICATE_BASE64`
- `P12_PASSWORD`
- `BUILD_PROVISION_PROFILE_BASE64`
- `KEYCHAIN_PASSWORD`

## Optional repository variable
- `APP_BUNDLE_ID` (set this if your provisioning profile expects a fixed bundle id)

> Important: If you use random bundle IDs, your provisioning profile must support that identifier. Most development profiles require a matching, explicit bundle id.

## Triggering builds
- Manual: Actions → **Build iOS IPA** → Run workflow.
- Automatic: push to `main`.

## Output
- Artifact: `MyFirstiOSApp-ipa`
- Release tag: `build-<run_number>` with attached `.ipa`
