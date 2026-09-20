## Cách build Gox cho macOS:
Bạn có thể tải mã nguồn về tự build Gox cho máy mình.

Yêu cầu:
- macOS 10.14 Mojave trở lên.
- Xcode 11 trở lên.
- (Tùy chọn) `create-dmg` để đóng gói bộ cài DMG: `brew install create-dmg`.

### Build bằng dòng lệnh (CLI):
```bash
xcodebuild -project Sources/OpenKey/macOS/Gox.xcodeproj -scheme Gox -configuration Release build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO MACOSX_DEPLOYMENT_TARGET=10.14 -derivedDataPath build/DerivedData
```
File ứng dụng `Gox.app` sẽ được tạo ra tại thư mục `build/DerivedData/Build/Products/Release/Gox.app`.

### Đóng gói bộ cài đặt DMG (Kéo thả vào Applications):
Sau khi build xong hoặc để script tự động build và đóng gói:
```bash
./scripts/package_dmg.sh
```
File cài đặt `build/Gox.dmg` sẽ được tạo ra với giao diện chuẩn macOS (ảnh nền, mũi tên chỉ dẫn kéo icon `Gox.app` vào thư mục `Applications`).

### Build bằng Xcode:
1. Mở `Sources/OpenKey/macOS/Gox.xcodeproj` bằng Xcode.
2. Chọn scheme **Gox**.
3. Bấm **Cmd + B** để biên dịch hoặc vào menu **Product -> Archive** để đóng gói.

Chúc các bạn build Gox cho macOS thành công!
