class Clickhouse < Formula
  desc "ClickHouse is a free analytic DBMS for big data."
  homepage "https://clickhouse.yandex"
  url "https://github.com/yandex/ClickHouse.git", :tag => "v1.1.54362-stable"
  version "v1.1.54362"

  head "https://github.com/yandex/ClickHouse.git"

  devel do
    url "https://github.com/yandex/ClickHouse.git", :tag => "v1.1.54378-stable"
  end

  depends_on "gcc"
  depends_on "llvm" => :build  
  depends_on "mysql" => :build
  depends_on "icu4c" => :build
  depends_on "cmake" => :build 
  depends_on "openssl" => :build
  depends_on "unixodbc" =>:build
  depends_on "gettext" => :build
  depends_on "libtool" => :build
  depends_on "readline" => :build
  
  bottle do
    root_url 'https://github.com/arduanov/homebrew-clickhouse/releases/download/v1.1.54362'
    sha256 "8019d148c781f7e0ddf9dff84e52b31df8abca23bf817172e7b8efcca0665135" => :high_sierra
    sha256 "8019d148c781f7e0ddf9dff84e52b31df8abca23bf817172e7b8efcca0665135" => :sierra
  end

  def install
    mkdir "#{var}/clickhouse"

    inreplace "dbms/src/Server/config.xml" do |s|
      s.gsub! "/var/lib/", "#{var}/lib/"
      s.gsub! "/var/log/", "#{var}/log/"
      s.gsub! "<!-- <max_open_files>262144</max_open_files> -->", "<max_open_files>262144</max_open_files>"
    end

    args = %W[
      -DENABLE_ICU=0,
      -DENABLE_TESTS=0,
      -DENABLE_TCMALLOC=0,
      -DUSE_INTERNAL_BOOST_LIBRARY=1
    ]

    mkdir "build" do
      system "cmake", "..", *std_cmake_args, *args
      system "make", "install"
    end
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
