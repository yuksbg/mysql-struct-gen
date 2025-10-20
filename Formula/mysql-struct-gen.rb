class MysqlStructGen < Formula
  desc "Generate Go structs directly from MySQL tables"
  homepage "https://github.com/yuksbg/mysql-struct-gen"
  version "0.0.0" # Auto-updated by GitHub Actions
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/yuksbg/mysql-struct-gen/releases/download/v1.0.2/mysql-struct-gen-darwin-amd64.tar.gz"
      sha256 "REPLACE_WITH_SHA256_DARWIN_AMD64"
    elsif Hardware::CPU.arm?
      url "https://github.com/yuksbg/mysql-struct-gen/releases/download/v1.0.2/mysql-struct-gen-darwin-arm64.tar.gz"
      sha256 "REPLACE_WITH_SHA256_DARWIN_ARM64"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/yuksbg/mysql-struct-gen/releases/download/v1.0.2/mysql-struct-gen-linux-amd64.tar.gz"
      sha256 "REPLACE_WITH_SHA256_LINUX_AMD64"
    elsif Hardware::CPU.arm?
      url "https://github.com/yuksbg/mysql-struct-gen/releases/download/v1.0.2/mysql-struct-gen-linux-arm64.tar.gz"
      sha256 "REPLACE_WITH_SHA256_LINUX_ARM64"
    end
  end

  def install
    bin.install "mysql-struct-gen"
  end

  test do
    system "#{bin}/mysql-struct-gen", "--version"
  end
end
