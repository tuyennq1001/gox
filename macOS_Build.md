## Cách build Gox cho macOS:
Bạn có thể tải mã nguồn về tự build Gox cho máy mình.

Yêu cầu:
- macOS 10.14 Mojave trở lên.
- Xcode 11 trở lên.

### Build bằng dòng lệnh (CLI):
```bash
xcodebuild -project Sources/OpenKey/macOS/Gox.xcodeproj -scheme Gox -configuration Release build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO MACOSX_DEPLOYMENT_TARGET=10.14
```
File ứng dụng `Gox.app` sẽ được tạo ra tại thư mục build của Xcode.

### Build bằng Xcode:
1. Mở `Sources/OpenKey/macOS/Gox.xcodeproj` bằng Xcode.
2. Chọn scheme **Gox**.
3. Bấm **Cmd + B** để biên dịch hoặc vào menu **Product -> Archive** để đóng gói.

Chúc các bạn build Gox cho macOS thành công!
