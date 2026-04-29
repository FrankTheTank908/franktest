# Frank the Tank iOS test app

This repo builds an **unsigned IPA** in GitHub Actions (no certificate/profile required in CI).

## App behavior
- Full-screen "Frank the Tank" themed background.
- A **Push me** button.
- Tapping the button shows popup: **Yay!**

## Unsigned IPA output
The workflow compiles with code signing disabled, then packages the built `.app` into:
- Artifact: `MyFirstiOSApp-unsigned-ipa`
- File: `MyFirstiOSApp-unsigned.ipa`
- Release tag on `main`: `unsigned-build-<run_number>`

## Inputs
- Optional repository variable: `APP_BUNDLE_ID`
  - If not set, `scripts/generate-config.sh` creates a random one like `com.autogen.<random>`.

## Triggering builds
- Manual: Actions → **Build Unsigned iOS IPA** → Run workflow.
- Automatic: push to `main`.

## Important
This IPA is unsigned by design. Install will require you to sign it yourself using your own certificate/provisioning flow.
