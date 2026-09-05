cask "yaxbar" do
  version "2.2.1-beta"
  sha256 "82fd49a8038edc1a61b7da931c6d585e51d7016784f1189d1c33b27126bbda53"

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
