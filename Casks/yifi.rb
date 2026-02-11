cask "yifi" do
  version :latest
  sha256 :no_check

  url "https://github.com/naumanahmad/yifi/releases/latest/download/yifi.zip"
  name "Yifi"
  desc "Menu bar app for monitoring network health"
  homepage "https://github.com/naumanahmad/yifi"

  app "yifi.app"

  caveats <<~EOS
    Yifi is distributed unsigned. macOS may block first launch.
    To open it:
      1. Control-click yifi in /Applications and choose Open.
      2. Click Open in the warning dialog.

    Or go to System Settings -> Privacy & Security and allow it there.
  EOS
end
