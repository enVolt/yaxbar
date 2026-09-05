#!/bin/bash
set -e

VERSION="${VERSION:-$(git describe --tags --always 2>/dev/null || echo "v2.2.2-beta")}"

echo ""
echo "  yaxbar ${VERSION}..."
echo ""
echo -n "${VERSION}" > .version
export PATH="$HOME/go/bin:$PATH"
export GOFLAGS="-buildvcs=false"
wails build -production -o YaxBar
