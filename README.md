# Gox — Bộ gõ Tiếng Việt thế hệ mới cho macOS

<p align="center">
  <a href="https://github.com/tuyennq1001/gox/releases/latest">
    <img src="https://img.shields.io/github/v/release/tuyennq1001/gox.svg?color=blue" alt="Latest Release">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-GPLv3-green.svg" alt="License">
  </a>
  <img src="https://img.shields.io/badge/Platform-macOS-lightgrey.svg" alt="Platform">
</p>

---

## Giới thiệu
**Gox** là bộ gõ tiếng Việt hiện đại, mã nguồn mở dành riêng cho macOS. Được thiết kế với triết lý **tối giản, siêu nhẹ, zero-telemetry**, Gox giải quyết triệt để lỗi gạch chân, kẹt phím, đúp chữ trên các trình duyệt hiện đại (Chrome, Safari, Edge) và hoạt động mượt mà trong môi trường lập trình (VS Code, Xcode, Terminal).

### Điểm nổi bật:
* 🚀 **Siêu nhẹ & Hiệu năng cao**: Hot-path xử lý phím bấm được tối ưu triệt để, không gây lag con trỏ hay đơ bàn phím.
* 🛡️ **Zero Telemetry**: Hoạt động hoàn toàn offline, cam kết 100% không ghi log phím bấm và không gửi dữ liệu ra ngoài.
* 🌐 **Hòa hợp tuyệt đối với CJK**: Tự động bypass khi chuyển qua bộ gõ tiếng Nhật, tiếng Hàn hoặc tiếng Trung.
* 🔄 **Chuyển chế độ thông minh**: Tự ghi nhớ chế độ Tiếng Việt/Tiếng Anh theo từng ứng dụng (Safari ↔ Terminal).
* 🎯 **Khắc phục lỗi gõ trên Browser**: Tích hợp cơ chế sửa lỗi đúp từ trên Omnibox trình duyệt Chromium và Safari.

---

## Hỗ trợ Kiểu gõ & Bảng mã

### Kiểu gõ:
- **Telex** / **Simple Telex 1, 2**
- **VNI**

### Bảng mã:
- **Unicode** (Dựng sẵn & Tổ hợp)
- **TCVN3 (ABC)**
- **VNI Windows**
- **Vietnamese Locale CP 1258**

---

## Các tính năng chính
- **Chuyển chế độ thông minh:** Tự động đổi Tiếng Việt/Tiếng Anh tương ứng với từng ứng dụng đang kích hoạt.
- **Tự ghi nhớ bảng mã:** Ghi nhớ bảng mã riêng biệt cho từng phần mềm (Photoshop, AutoCAD, IDE...).
- **Macro (Gõ tắt):** Hỗ trợ danh sách gõ tắt không giới hạn độ dài ký tự.
- **Tạm tắt nhanh:** Nhấn phím `Command` hoặc `Ctrl` để tạm tắt bộ gõ khi cần gõ mã code hay phím tắt.
- **Sửa lỗi gạch chân & Autocorrect:** Triệt tiêu hiện tượng gạch chân khó chịu trên macOS.
- **Viết hoa đầu câu tự động:** Tự động viết hoa sau dấu chấm câu và khi xuống dòng.
- **Công cụ chuyển mã tiện lợi:** Chuyển đổi nhanh giữa các chuẩn mã hóa trong Clipboard.

---

## Cài đặt & Sử dụng

### 1. Tải về và cài đặt
1. Tải file cài đặt `.dmg` bản mới nhất từ [GitHub Releases](https://github.com/tuyennq1001/gox/releases/latest).
2. Mở file `.dmg` và kéo biểu tượng **`Gox.app`** vào thư mục **`Applications`**.

### 2. Cấp quyền Trợ năng (Accessibility)
Để Gox có thể gửi phím tiếng Việt vào hệ thống, bạn cần cấp quyền Trợ năng:
1. Mở **Cài đặt hệ thống (System Settings)** ➔ **Quyền riêng tư & Bảo mật (Privacy & Security)** ➔ **Trợ năng (Accessibility)**.
2. Bật công tắc cho **`Gox`**. *(Nếu đã có trong danh sách, hãy gạt tắt rồi bật lại)*.

> [!TIP]
> Hãy tắt hẳn bộ gõ tiếng Việt mặc định của macOS để tránh xung đột phím bấm.

---

## Tự Build từ Mã nguồn
Yêu cầu macOS 10.14 trở lên và Xcode 11 trở lên:
```bash
git clone https://github.com/tuyennq1001/gox.git
cd gox
xcodebuild -project Sources/OpenKey/macOS/OpenKey.xcodeproj -scheme Gox build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```
Chi tiết xem thêm tại [macOS_Build.md](macOS_Build.md).

---

## Đóng góp & Báo lỗi
Mọi ý kiến đóng góp, báo lỗi hoặc yêu cầu tính năng mới xin vui lòng gửi qua:
- **Báo lỗi & Thảo luận**: [GitHub Issues](https://github.com/tuyennq1001/gox/issues)
- **Pull Requests**: [GitHub PRs](https://github.com/tuyennq1001/gox/pulls)

---

## Ghi nhận & Bản quyền (Credits & License)
- Phát triển và duy trì bởi **Terry Nguyen** ([@tuyennq1001](https://github.com/tuyennq1001)).
- Kế thừa nền tảng thuật toán từ dự án mã nguồn mở OpenKey của tác giả **Mai Vũ Tuyên**.
- Được phát hành dưới giấy phép mã nguồn mở [GNU General Public License v3.0](LICENSE).
