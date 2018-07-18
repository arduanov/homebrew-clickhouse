class Clickhouse < Formula
  desc "ClickHouse is a free analytic DBMS for big data."
  homepage "https://clickhouse.yandex"
  url "https://github.com/yandex/ClickHouse.git", :tag => "v1.1.54383-stable"
  version "1.1.54383"

  head "https://github.com/yandex/ClickHouse.git"

  devel do
    url "https://github.com/yandex/ClickHouse.git", :tag => "v1.1.54394-stable"
  end

  depends_on "gcc"
  depends_on "mysql@5.7" => :build
  depends_on "icu4c" => :build
  depends_on "cmake" => :build 
  depends_on "openssl" => :build
  depends_on "unixodbc" =>:build
  depends_on "libtool" => :build
  depends_on "gettext" => :build
  depends_on "zlib" => :build
  depends_on "readline" => :build
  
  bottle do
    root_url 'https://github.com/arduanov/homebrew-clickhouse/releases/download/v1.1.54383'
    sha256 "646d98c692442f3330649838196296b37ae5ccfb49a51f1e0df89dc8e2dd1a0e" => :high_sierra
  end

  def install
    inreplace "libs/libmysqlxx/cmake/find_mysqlclient.cmake", "/usr/local/opt/mysql/lib", "/usr/local/opt/mysql@5.7/lib"
    inreplace "libs/libmysqlxx/cmake/find_mysqlclient.cmake", "/usr/local/opt/mysql/include", "/usr/local/opt/mysql@5.7/include"

    inreplace "dbms/programs/server/config.xml" do |s|
      s.gsub! "/var/lib/", "#{var}/lib/"
      s.gsub! "/var/log/", "#{var}/log/"
      s.gsub! "<!-- <max_open_files>262144</max_open_files> -->", "<max_open_files>262144</max_open_files>"
    end

    args = %W[
      -DENABLE_ICU=0
      -DENABLE_TESTS=0
      -DENABLE_TCMALLOC=0
      -DUSE_INTERNAL_BOOST_LIBRARY=1
      -DENABLE_EMBEDDED_COMPILER=0
      -DUSE_INTERNAL_LLVM_LIBRARY=1
    ]

    mkdir "build" do
      system "cmake", "..", *std_cmake_args, *args
      system "make"
    end

    bin.install "#{buildpath}/build/dbms/programs/clickhouse"
    bin.install_symlink "clickhouse" => "clickhouse-client"
    bin.install_symlink "clickhouse" => "clickhouse-server"
    bin.install_symlink "clickhouse" => "clickhouse-local"
    bin.install_symlink "clickhouse" => "clickhouse-compressor"
    bin.install_symlink "clickhouse" => "clickhouse-copier"
    bin.install_symlink "clickhouse" => "clickhouse-format"
    bin.install_symlink "clickhouse" => "clickhouse-lld"
    bin.install_symlink "clickhouse" => "clickhouse-obfuscator"
    bin.install_symlink "clickhouse" => "clickhouse-clang"

    mkdir "#{etc}/clickhouse-client/"
    (etc/"clickhouse-client").install "#{buildpath}/dbms/programs/client/clickhouse-client.xml"

    mkdir "#{etc}/clickhouse-server/"
    (etc/"clickhouse-server").install "#{buildpath}/dbms/programs/server/config.xml"
    (etc/"clickhouse-server").install "#{buildpath}/dbms/programs/server/users.xml"
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
