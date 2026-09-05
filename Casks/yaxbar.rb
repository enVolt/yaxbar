cask "yaxbar" do
  version "2.2.2-beta"
  sha256 "b55a61b2e6b6ab4c600d02d1f8e216eff20717224765aafe6ddad4d18699db2d"

  url "https://github.com/enVolt/yaxbar/releases/download/v#{version}/yaxbar.v#{version}.dmg"
  name "yaxbar"
  desc "Put anything into your macOS menu bar (maintained xbar fork)"
  homepage "https://github.com/enVolt/yaxbar"

  app "yaxbar.app"

  zap trash: [
    "~/Library/Application Support/xbar",
    "~/Library/Application Support/yaxbar",
    "~/Library/Preferences/com.envolt.yaxbar.plist",
  ]
end
