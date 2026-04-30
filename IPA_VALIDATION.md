# NetProof IPA Packaging & Validation Guide

If your generated `.ipa` is only ~65 KB, that usually means you exported a wrapper without an app payload (or exported the wrong artifact).

## What an IPA must contain

A valid iOS IPA is a ZIP archive with at least:

- `Payload/NetProof.app/NetProof` (Mach-O executable)
- `Payload/NetProof.app/Info.plist`
- `Payload/NetProof.app/Frameworks/` (only dynamic frameworks your app embeds)
- `Payload/NetProof.app/_CodeSignature/`

> iOS system SDKs (UIKit, SwiftUI, Foundation, Network, etc.) are **not** embedded in IPA. They are provided by iOS.

## Why IPA can be tiny

Common causes:

1. Exported wrong file (e.g., empty package or metadata only)
2. Build failed but export still produced a shell
3. App target has no compiled sources/resources
4. Wrong scheme/configuration selected
5. Archive not created from `Any iOS Device (arm64)`

## Size expectations

For this NetProof scaffold, debug/device IPAs are typically many MB, not KB. 65 KB is invalid for a functional app.

## Validate IPA locally

```bash
unzip -l NetProof.ipa | head -n 40
unzip -l NetProof.ipa | rg 'Payload/.+\.app/(NetProof|Info.plist|Frameworks/)'
```

Check binary exists and is non-trivial:

```bash
tmpdir=$(mktemp -d)
unzip -q NetProof.ipa -d "$tmpdir"
ls -lh "$tmpdir/Payload/NetProof.app/NetProof"
file "$tmpdir/Payload/NetProof.app/NetProof"
```

## Xcode archive settings checklist

- Scheme: `NetProof` (app target)
- Destination: `Any iOS Device (arm64)`
- Product → Archive
- Organizer → Distribute App → App Store Connect / Ad Hoc
- Build Settings:
  - `SKIP_INSTALL = NO` for app target
  - `BUILD_LIBRARY_FOR_DISTRIBUTION = YES` only for distributable frameworks (optional)
- Signing configured for release

## Framework guidance

Only embed third-party dynamic frameworks you ship. Do **not** try to embed Apple SDK frameworks manually.

- Embed & Sign: custom dynamic frameworks required by app
- Do Not Embed: Apple system frameworks

