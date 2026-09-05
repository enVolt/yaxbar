#!/bin/bash

set -e

export PATH="$HOME/go/bin:$PATH"
export GOFLAGS="-buildvcs=false"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${VERSION:-$(git describe --tags --always 2>/dev/null || echo "v2.2.2-beta")}"

echo ""
echo "  Packaging yaxbar ${VERSION}..."
echo ""
echo -n "${VERSION}" > .version

# Run tests
./test.sh

rm -rf ./build/bin
mkdir -p ./build/bin
mkdir -p "${REPO_ROOT}/Casks"

sed "s/0.0.0/${VERSION}/" ./build/darwin/Info.plist.src > ./build/darwin/Info.plist

echo "Building universal binary..."
CGO_LDFLAGS=-mmacosx-version-min=10.13 wails build -package -production -platform darwin/universal -o YaxBar

cd ./build/bin/

SIGNING_IDENTITY="${YAXBAR_SIGNING_IDENTITY:-${XBAR_SIGNING_IDENTITY:--}}"
echo "Signing the binary with identity: ${SIGNING_IDENTITY}..."
codesign --force --deep -s "${SIGNING_IDENTITY}" -o runtime -v "./YaxBar.app"

echo "Creating DMG..."
if command -v create-dmg >/dev/null 2>&1; then
    create-dmg ./YaxBar.app --overwrite --dmg-title "Install YaxBar" || true
    mv yaxbar*.dmg "yaxbar.${VERSION}.dmg"
else
    echo "Using native hdiutil to create DMG..."
    rm -f "yaxbar.${VERSION}.dmg"
    hdiutil create -volname "YaxBar" -srcfolder ./YaxBar.app -ov -format UDZO "yaxbar.${VERSION}.dmg"
fi

echo "Zipping..."
rm -f "yaxbar.${VERSION}.zip"
zip -r -y "yaxbar.${VERSION}.zip" ./YaxBar.app

echo "Computing SHA256 checksums..."
shasum -a 256 "yaxbar.${VERSION}.dmg" > "yaxbar.${VERSION}.dmg.sha256"
shasum -a 256 "yaxbar.${VERSION}.zip" > "yaxbar.${VERSION}.zip.sha256"

DMG_SHA=$(cat "yaxbar.${VERSION}.dmg.sha256" | awk '{print $1}')
echo ""
echo "=============================================="
echo "  yaxbar ${VERSION} packaged successfully!"
echo "  DMG:    ./build/bin/yaxbar.${VERSION}.dmg"
echo "  SHA256: ${DMG_SHA}"
echo "=============================================="
echo ""

# Generate / update Casks/yaxbar.rb
RAW_VERSION="${VERSION#v}"
cat << EOF > "${REPO_ROOT}/Casks/yaxbar.rb"
cask "yaxbar" do
  version "${RAW_VERSION}"
  sha256 "${DMG_SHA}"

  url "https://github.com/enVolt/yaxbar/releases/download/v#{version}/yaxbar.v#{version}.dmg"
  name "YaxBar"
  desc "Put anything into your macOS menu bar (maintained xbar fork)"
  homepage "https://github.com/enVolt/yaxbar"

  auto_updates true

  app "YaxBar.app"

  zap trash: [
    "~/Library/Application Support/xbar",
    "~/Library/Application Support/yaxbar",
    "~/Library/Preferences/com.envolt.yaxbar.plist",
  ]
end
EOF

# Notarization (optional, only if credentials provided)
if [[ -n "${AC_KEYCHAIN_PROFILE}" ]]; then
    echo "Notarizing with notarytool profile ${AC_KEYCHAIN_PROFILE}..."
    xcrun notarytool submit "yaxbar.${VERSION}.zip" --keychain-profile "${AC_KEYCHAIN_PROFILE}" --wait
    xcrun stapler staple "yaxbar.${VERSION}.dmg"
elif [[ -n "${AC_USERNAME}" && -n "${AC_PASSWORD}" ]]; then
    echo "Notarizing with notarytool credentials..."
    xcrun notarytool submit "yaxbar.${VERSION}.zip" --apple-id "${AC_USERNAME}" --password "${AC_PASSWORD}" --team-id "${AC_PROVIDER}" --wait
    xcrun stapler staple "yaxbar.${VERSION}.dmg"
else
    echo "Skipping notarization (no Apple Developer credentials provided)."
fi

echo "Done!"
