#!/usr/bin/env bash
set -euo pipefail
id -u netproof >/dev/null 2>&1 || useradd -m -s /bin/bash netproof
mkdir -p /opt/netproof
cp -r /tmp/netproof-repo/server /opt/netproof/server
chown -R netproof:netproof /opt/netproof
cd /opt/netproof/server
npm install --omit=dev
systemctl daemon-reload
systemctl enable netproof-upload
