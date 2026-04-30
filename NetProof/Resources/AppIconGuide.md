# Modern App Icon Guide (NetProof)

Current icon appears blank because no final icon asset was provided.

## Recommended concept

- Dark navy background gradient
- White/teal pulse waveform + shield checkmark
- Subtle grid dots to signal network diagnostics
- High contrast for dark/light wallpapers

## Required sizes

Use Xcode Asset Catalog to provide all iPhone/iPad icon slots from a single 1024x1024 source.

## Fast generation flow

1. Design 1024x1024 in Figma/Sketch.
2. Export PNG.
3. Drop into `Assets.xcassets > AppIcon` “Single Size” slot (Xcode will scale).
4. Verify on device home screen and Settings.
