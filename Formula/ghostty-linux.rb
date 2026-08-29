class GhosttyLinux < Formula
  desc "Homebrew-managed Ghostty build for Fedora Linux"
  homepage "https://ghostty.org/"
  url "https://download.copr.fedorainfracloud.org/results/scottames/ghostty/fedora-44-x86_64/10851188-ghostty/ghostty-1.3.1-4.fc44.x86_64.rpm",
      using: :nounzip
  version "1.3.1-4.fc44"
  sha256 "d688483de73a295b84a87e2fe4873e9645de4934ba5459294c02966f9e190dfc"
  license "MIT"

  depends_on :linux

  def install
    system "bash", "-c", "rpm2cpio #{cached_download} | cpio -idm --quiet"

    desktop = buildpath/"usr/share/applications/com.mitchellh.ghostty.desktop"
    dbus_service = buildpath/"usr/share/dbus-1/services/com.mitchellh.ghostty.service"
    systemd_service = buildpath/"usr/share/systemd/user/app-com.mitchellh.ghostty.service"
    inreplace desktop, "/usr/bin/ghostty", opt_bin/"ghostty"
    inreplace dbus_service, "/usr/bin/ghostty", opt_bin/"ghostty"
    inreplace systemd_service, "/usr/bin/ghostty", opt_bin/"ghostty"

    libexec.mkpath
    lib.mkpath
    share.mkpath
    system "cp", "--no-preserve=context", "usr/bin/ghostty", libexec/"ghostty-bin"
    system "cp", "-a", "--no-preserve=context", "usr/lib/.", lib
    system "cp", "-a", "--no-preserve=context", "usr/share/.", share
    (bin/"ghostty").write_env_script libexec/"ghostty-bin",
                                      GHOSTTY_RESOURCES_DIR: opt_share/"ghostty"

    updater = Pathname(__dir__).parent/"scripts/ghostty-linux-update"
    system "cp", "--no-preserve=context", updater, bin/"ghostty-linux-update"
    chmod 0755, bin/"ghostty-linux-update"
  end

  def caveats
    <<~EOS
      Ghostty uses Fedora's GTK runtime and keeps desktop integration under
      #{opt_share}. Link that directory into ~/.local/share for GNOME.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ghostty --version")
  end
end
