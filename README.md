# Homebrew ClickHouse Tap

Latest builds of [ClickHouse](https://clickhouse.yandex) for MacOS High Sierra.

Build without ICU, support for collations and charset conversion functions disabled

## Installation

### Add homebrew tap

```bash
brew tap arduanov/clickhouse
```

### Install ClickHouse
```bash
brew install clickhouse
```

### Or compile from sources
```bash
brew install cmake gcc mysql unixodbc readline gettext icu4c llvm openssl libtool
brew install clickhouse --cc=gcc-7
```

