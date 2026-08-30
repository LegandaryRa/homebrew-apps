class T3CodeLinux < Formula
  desc "Homebrew-managed T3 Code launcher and stable Linux updater"
  homepage "https://github.com/pingdotgg/t3code"
  url "https://github.com/pingdotgg/t3code/releases/download/v0.0.36/T3-Code-0.0.36-x86_64.AppImage"
  sha256 "f19c36ce903331f8d5906f2f90e6fbaae576fde53ab37e1eeb201f3c50c9acf1"
  license "MIT"

  depends_on arch: :x86_64
  depends_on "jq"
  depends_on :linux

  def install
    appimage = Dir["T3-Code-*-x86_64.AppImage"].first
    libexec.install appimage => "bootstrap.AppImage"
    chmod 0755, libexec/"bootstrap.AppImage"

    scripts = Pathname(__dir__).parent/"scripts"
    cp scripts/"t3-code", buildpath/"t3-code"
    cp scripts/"t3-code-update", buildpath/"t3-code-update"
    cp scripts/"t3-code-integrate", buildpath/"t3-code-integrate"

    assets = Pathname(__dir__).parent/"assets"
    desktop = buildpath/"t3-code.desktop"
    cp assets/"t3-code.desktop.in", desktop
    inreplace desktop, "@T3_CODE_BIN@", opt_bin/"t3-code"
    inreplace desktop, "@T3_CODE_ICON@", opt_share/"icons/hicolor/512x512/apps/t3-code.png"

    inreplace buildpath/"t3-code-integrate", "@BREW@", HOMEBREW_PREFIX/"bin/brew"
    inreplace buildpath/"t3-code-integrate", "@DESKTOP_FILE@", opt_share/"applications/t3-code.desktop"
    inreplace buildpath/"t3-code-integrate", "@UPDATE@", opt_bin/"t3-code-update"

    libexec.install buildpath/"t3-code", buildpath/"t3-code-update", buildpath/"t3-code-integrate"
    chmod 0755, libexec/"t3-code"
    chmod 0755, libexec/"t3-code-update"
    chmod 0755, libexec/"t3-code-integrate"
    bin.install_symlink libexec/"t3-code"
    bin.install_symlink libexec/"t3-code-update"
    bin.install_symlink libexec/"t3-code-integrate"

    system libexec/"bootstrap.AppImage", "--appimage-extract",
           "usr/share/icons/hicolor/512x512/apps/t3code.png"
    (share/"icons/hicolor/512x512/apps").install \
      buildpath/"squashfs-root/usr/share/icons/hicolor/512x512/apps/t3code.png" => "t3-code.png"
    (share/"applications").install desktop
  end

  def caveats
    <<~EOS
      T3 release payloads are stored in ~/.local/share/t3-code/releases.
      Install the desktop entry and enable daily updates with:
        t3-code-integrate install
    EOS
  end

  service do
    run [opt_bin/"t3-code-update"]
    run_type :interval
    interval 86_400
  end

  test do
    assert_predicate libexec/"bootstrap.AppImage", :executable?
    assert_match "Version:", shell_output("#{libexec}/bootstrap.AppImage --appimage-version 2>&1")

    mock_data = testpath/"data/t3-code"
    mock_data.mkpath
    (mock_data/"current").write <<~SH
      #!/bin/sh
      printf 'extract=%s args=%s\\n' "$APPIMAGE_EXTRACT_AND_RUN" "$*"
    SH
    chmod 0755, mock_data/"current"
    output = shell_output("XDG_DATA_HOME=#{testpath}/data #{bin}/t3-code --launcher-test")
    assert_equal "extract=1 args=--no-sandbox --launcher-test", output.strip

    assert_match "usage:", shell_output("#{bin}/t3-code-update --help")

    system "env", "XDG_DATA_HOME=#{testpath}/integration",
           bin/"t3-code-integrate", "install", "--no-service"
    desktop = testpath/"integration/applications/t3-code.desktop"
    assert_predicate desktop, :file?
    assert_match (opt_bin/"t3-code").to_s, desktop.read

    system "env", "XDG_DATA_HOME=#{testpath}/integration",
           bin/"t3-code-integrate", "uninstall", "--no-service"
    refute_path_exists desktop
  end
end
