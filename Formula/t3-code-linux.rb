class T3CodeLinux < Formula
  desc "Homebrew-managed T3 Code launcher and stable Linux updater"
  homepage "https://github.com/pingdotgg/t3code"
  url "https://github.com/pingdotgg/t3code/releases/download/v0.0.36/T3-Code-0.0.36-x86_64.AppImage"
  version "0.0.36"
  sha256 "f19c36ce903331f8d5906f2f90e6fbaae576fde53ab37e1eeb201f3c50c9acf1"
  license "MIT"

  depends_on "jq"

  def install
    appimage = Dir["T3-Code-*-x86_64.AppImage"].first
    libexec.install appimage => "bootstrap.AppImage"

    scripts = Pathname(__dir__).parent/"scripts"
    FileUtils.cp scripts/"t3-code", buildpath/"t3-code"
    FileUtils.cp scripts/"t3-code-update", buildpath/"t3-code-update"
    libexec.install buildpath/"t3-code"
    libexec.install buildpath/"t3-code-update"
    bin.install_symlink libexec/"t3-code"
    bin.install_symlink libexec/"t3-code-update"
  end

  def caveats
    <<~EOS
      T3 release payloads are stored in ~/.local/share/t3-code/releases.
      Run t3-code-update once after installation, then enable the user timer.
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/t3-code-update --help")
  end
end
