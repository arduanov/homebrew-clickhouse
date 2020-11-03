class Clickhouse < Formula
  desc "ClickHouse is a free analytic DBMS for big data."
  homepage "https://clickhouse.yandex"
  url "https://github.com/yandex/ClickHouse.git", :tag => "v20.10.3.30-stable"
  version "20.10.3.30"

  head "https://github.com/yandex/ClickHouse.git"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build
  depends_on "llvm" => :build
  
  bottle do
    root_url "https://homebrew.bintray.com/bottles-clickhouse"
    sha256 "3bd989f4fa2ee09e0abb7af989ee5c537f032633ea0c077c8d1ca78653eb7740" => :catalina
  end

  def install
    inreplace "programs/server/config.xml" do |s|
      s.gsub! "/var/lib/", "#{var}/lib/"
      s.gsub! "/var/log/", "#{var}/log/"
      s.gsub! "<!-- <max_open_files>262144</max_open_files> -->", "<max_open_files>262144</max_open_files>"
    end
    inreplace "cmake/warnings.cmake" do |s|
      s.gsub! "add_warning(frame-larger-than=32768)", "add_warning(frame-larger-than=131072)"
    end

    args = %W[
      -DENABLE_TESTS=0
      -DUSE_RDKAFKA=0
      -DCMAKE_CXX_COMPILER=/usr/local/opt/llvm/bin/clang++
      -DCMAKE_C_COMPILER=/usr/local/opt/llvm/bin/clang
    ]

    mkdir "build" do
      system "cmake", "..", *std_cmake_args, *args
      system "ninja"
    end

    bin.install "#{buildpath}/build/programs/clickhouse"
    bin.install_symlink "clickhouse" => "clickhouse-benchmark"
    bin.install_symlink "clickhouse" => "clickhouse-clang"
    bin.install_symlink "clickhouse" => "clickhouse-client"
    bin.install_symlink "clickhouse" => "clickhouse-compressor"
    bin.install_symlink "clickhouse" => "clickhouse-copier"
    bin.install_symlink "clickhouse" => "clickhouse-extract-from-config"
    bin.install_symlink "clickhouse" => "clickhouse-format"
    bin.install_symlink "clickhouse" => "clickhouse-lld"
    bin.install_symlink "clickhouse" => "clickhouse-local"
    bin.install_symlink "clickhouse" => "clickhouse-obfuscator"
    bin.install_symlink "clickhouse" => "clickhouse-odbc-bridge"
    bin.install_symlink "clickhouse" => "clickhouse-performance-test"
    bin.install_symlink "clickhouse" => "clickhouse-server"


    mkdir "#{etc}/clickhouse-client/"
    (etc/"clickhouse-client").install "#{buildpath}/programs/client/clickhouse-client.xml"

    mkdir "#{etc}/clickhouse-server/"
    (etc/"clickhouse-server").install "#{buildpath}/programs/server/config.xml"
    (etc/"clickhouse-server").install "#{buildpath}/programs/server/users.xml"
  end

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>ProgramArguments</key>
      <array>
          <string>#{opt_bin}/clickhouse-server</string>
          <string>--config-file</string>
          <string>#{etc}/clickhouse-server/config.xml</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/clickhouse-client", "--version"
  end
end
