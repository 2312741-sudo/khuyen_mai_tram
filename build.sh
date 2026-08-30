#!/bin/bash
set -e

echo "=== [1/4] Tối ưu hóa môi trường Vercel ==="
git config --global --add safe.directory '*' || true

# Tải Flutter siêu tốc
if [ ! -d "flutter" ]; then
  echo "=== [2/4] Tải Flutter SDK tối ưu (shallow clone) ==="
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 --single-branch --no-tags flutter
fi

export PATH="$PWD/flutter/bin:$PATH"

# Tắt analytics để tiết kiệm thời gian
flutter config --no-analytics > /dev/null 2>&1 || true

echo "=== [3/4] Cài đặt dependencies ==="
flutter pub get --no-precompile

echo "=== [4/4] Biên dịch Flutter Web tối ưu (O4 Minified) ==="
flutter build web --release --no-wasm-dry-run --no-tree-shake-icons

echo "=== Hoàn tất biên dịch siêu tốc! ==="
