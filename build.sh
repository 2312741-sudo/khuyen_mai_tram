#!/bin/bash
set -e

echo "=== Cấu hình môi trường Vercel cho Flutter ==="
git config --global --add safe.directory '*' || true

if [ ! -d "flutter" ]; then
  echo ">>> Đang tải Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
fi

export PATH="$PWD/flutter/bin:$PATH"

echo ">>> Kiểm tra phiên bản Flutter..."
flutter --version

echo ">>> Tải dependencies..."
flutter pub get

echo ">>> Đang biên dịch Flutter Web..."
flutter build web --release

echo "=== Biên dịch thành công! ==="
