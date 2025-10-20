class MysqlStructGen < Formula
  desc "Generate Go structs directly from MySQL tables"
  homepage "https://github.com/yuksbg/mysql-struct-gen"
  version "1.0.5" # Auto-updated by GitHub Actions
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/yuksbg/mysql-struct-gen/releases/download/v1.0.5/mysql-struct-gen-darwin-amd64.tar.gz"
      sha256 "3e637d588e75404fa09bfe359973aaf005fb22d5ac319f640785eca395e04cf9"
    elsif Hardware::CPU.arm?
      url "https://github.com/yuksbg/mysql-struct-gen/releases/download/v1.0.5/mysql-struct-gen-darwin-arm64.tar.gz"
      sha256 "07d9390211c047f66c34e4f4fc4446d8d79f4e749752d48e128ba0c624897bdf"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/yuksbg/mysql-struct-gen/releases/download/v1.0.5/mysql-struct-gen-linux-amd64.tar.gz"
      sha256 "a38f5979473a9e7498f747f830e7542d74699eeb30e01d3cee5f2cb28bbbb13a"
    elsif Hardware::CPU.arm?
      url "https://github.com/yuksbg/mysql-struct-gen/releases/download/v1.0.5/mysql-struct-gen-linux-arm64.tar.gz"
      sha256 "316fdd8a63bb035fd81dcf5a11956028862e28ae93626cd828de03607cb5d987"
    end
  end

  def install
    bin.install "mysql-struct-gen"
  end

  test do
    system "#{bin}/mysql-struct-gen", "--version"
  end
end
