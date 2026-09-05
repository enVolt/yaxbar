cask "yaxbar" do
  version "2.2.3-beta"
  sha256 "61dcc7e14f2c7e79bd9bb662bc3c57f3012fcff9d26e4454dbd6e438955ebaf4"

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
