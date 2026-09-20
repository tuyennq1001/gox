#!/bin/bash
set -euo pipefail

# ==============================================================================
# Script đóng gói Gox DMG Installer cho macOS với giao diện kéo thả trực quan
# ==============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== [1/4] Kiểm tra công cụ cần thiết ==="
if ! command -v create-dmg >/dev/null 2>&1; then
    echo "Lỗi: 'create-dmg' chưa được cài đặt."
    echo "Vui lòng cài đặt qua Homebrew bằng lệnh:"
    echo "    brew install create-dmg"
    exit 1
fi
echo "✔ create-dmg: $(create-dmg --version)"

# 2. Kiểm tra/Biên dịch Gox.app
echo "=== [2/4] Kiểm tra binary Gox.app ==="
APP_PATH="build/DerivedData/Build/Products/Release/Gox.app"
if [[ ! -d "$APP_PATH" ]]; then
    echo "Chưa tìm thấy Gox.app bản Release, tiến hành build bằng xcodebuild..."
    xcodebuild -project Sources/OpenKey/macOS/Gox.xcodeproj \
               -scheme Gox \
               -configuration Release \
               build \
               CODE_SIGN_IDENTITY="" \
               CODE_SIGNING_REQUIRED=NO \
               CODE_SIGNING_ALLOWED=NO \
               MACOSX_DEPLOYMENT_TARGET=10.14 \
               -derivedDataPath build/DerivedData
fi

if [[ ! -d "$APP_PATH" ]]; then
    echo "Lỗi: Không tìm thấy $APP_PATH sau khi build."
    exit 1
fi
echo "✔ Gox.app sẵn sàng tại: $APP_PATH"

# 3. Tạo ảnh nền nếu chưa có
echo "=== [3/4] Kiểm tra tài nguyên hình ảnh ==="
BG_IMG="assets/dmg_background.tiff"
if [[ ! -f "$BG_IMG" ]]; then
    echo "Đang tạo ảnh nền DMG chuẩn HiDPI (Retina)..."
    python3 scripts/generate_dmg_background.py
fi
echo "✔ Ảnh nền HiDPI sẵn sàng: $BG_IMG"

# 4. Ký mã Designated Requirement bảo toàn quyền Accessibility
echo "=== [4/5] Ký mã Designated Requirement: com.tuyennq1001.gox ==="
codesign --force --deep --sign - --requirements '=designated => identifier "com.tuyennq1001.gox"' "$APP_PATH"
echo "✔ Ký mã thành công."

VOL_ICON="Sources/OpenKey/macOS/ModernKey/Resources/Icon.icns"
OUTPUT_DIR="build"
OUTPUT_DMG="$OUTPUT_DIR/Gox.dmg"
OUTPUT_ZIP="$OUTPUT_DIR/Gox.zip"

mkdir -p "$OUTPUT_DIR"

# 5. Đóng gói DMG bằng create-dmg & ZIP cho Auto-Update
echo "=== [5/5] Đang đóng gói DMG và ZIP ==="
create-dmg \
    --volname "Gox Installer" \
    --volicon "$VOL_ICON" \
    --background "$BG_IMG" \
    --window-pos 200 120 \
    --window-size 660 400 \
    --icon-size 128 \
    --text-size 12 \
    --icon "Gox.app" 180 185 \
    --hide-extension "Gox.app" \
    --app-drop-link 480 185 \
    --overwrite \
    "$OUTPUT_DMG" \
    "$APP_PATH"

echo "Đang nén Gox.zip cho In-App Auto-Update..."
rm -f "$OUTPUT_ZIP"
ditto -c -k --keepParent "$APP_PATH" "$OUTPUT_ZIP"

echo ""
echo "=================================================="
echo "✔ ĐÓNG GÓI THÀNH CÔNG!"
echo "File DMG:   $OUTPUT_DMG ($(du -h "$OUTPUT_DMG" | cut -f1))"
echo "File ZIP:   $OUTPUT_ZIP ($(du -h "$OUTPUT_ZIP" | cut -f1))"
echo "=================================================="
