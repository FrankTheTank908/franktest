# NetProof Raspberry Pi 5 Upload Server Image

Custom Raspberry Pi 5 image pipeline with NetProof upload server preinstalled.

## Build with GitHub Actions

Run workflow `Build Pi5 Image`, download image artifact, flash to SD card.

Defaults:
- user/password: `netproof` / `netproof123` (change on first boot)
- upload-only mode enabled
- allowed origin: `http://franksplex.com`

Edit `/etc/default/netproof-upload` and restart service if needed.
