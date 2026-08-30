#!/bin/bash
set -e

echo "=== [1/4] Tối ưu hóa môi trường Vercel ==="
git config --global --add safe.directory '*' || true

# Tải Flutter SDK với tags để nhận diện đúng phiên bản Flutter
if [ ! -d "flutter" ]; then
  echo "=== [2/4] Tải Flutter SDK ==="
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
fi

export PATH="$PWD/flutter/bin:$PATH"

# Tắt analytics để tiết kiệm thời gian
flutter config --no-analytics > /dev/null 2>&1 || true

echo "=== [3/4] Cài đặt dependencies ==="
flutter pub get

echo "=== [4/4] Biên dịch Flutter Web tối ưu ==="
flutter build web --release --no-wasm-dry-run --no-tree-shake-icons

echo "=== Hoàn tất biên dịch thành công! ==="
