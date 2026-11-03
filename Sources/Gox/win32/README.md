# Gox for Windows
[![GitHub release](https://img.shields.io/github/v/release/tuyennq1001/gox.svg?color=blue)](https://github.com/tuyennq1001/gox/releases/latest)
[![License: GPLv3](https://img.shields.io/badge/License-GPLv3-green.svg)](https://github.com/tuyennq1001/gox/blob/master/LICENSE)

**Gox for Windows** — Gõ Tiếng Việt & Tiếng Nhật song hành không độ trễ. Phiên bản dành cho Windows thừa hưởng trọn vẹn lõi thuật toán C++ tối ưu, tương thích hoàn hảo với bộ gõ tiếng Nhật của hệ điều hành (Microsoft Japanese IME) và bộ gõ tiếng Việt.

---

## Điểm nổi bật trên Windows
* 🇯🇵 **Tự động Bypass khi gõ Tiếng Nhật**: Tích hợp cơ chế kiểm tra trạng thái IME (`ImmGetDefaultIMEWnd` + `IMC_GETOPENSTATUS`). Khi bạn mở IME tiếng Nhật, Gox tự động nhả phím nguyên bản, không làm vỡ bộ đệm tổ hợp Romaji ➔ Hiragana/Kanji.
* 🎮 **Hỗ trợ gõ trong Game & Đồ họa**: Chạy với quyền `Administrator` giúp gõ tiếng Việt mượt mà trong các tựa game (LMHT, Valorant, Dota...) và phần mềm kỹ thuật (Photoshop, AutoCAD...).
* 🛡️ **Zero Telemetry**: Hoạt động hoàn toàn offline, cam kết 100% không ghi log phím bấm và không gửi bất kỳ dữ liệu nào ra Internet.
* 🚀 **Hiệu năng cao**: Hot-path xử lý phím bấm Win32 Hook được tối ưu triệt để, không gây giật lag chuột hay delay phím bấm.

---

## Tính năng chính
* **Kiểu gõ**: Telex, VNI, Simple Telex 1 & 2.
* **Bảng mã**: Unicode dựng sẵn, Unicode tổ hợp, TCVN3 (ABC), VNI Windows, Vietnamese Locale CP 1258.
* **Chính tả thông minh**: Bật/tắt kiểm tra chính tả, tự khôi phục từ sai, cho phép phụ âm đầu `z w j f`.
* **Phím tắt chuyển đổi**: Tự do cấu hình phím tắt chuyển Anh - Việt (`Ctrl + Shift`, `Alt + Z`...).
* **Ghi nhớ thông minh theo ứng dụng**: Tự động chuyển bảng mã và chế độ gõ tương ứng với từng phần mềm.
* **Gõ tắt & Chuyển mã Clipboard**: Hỗ trợ danh sách Macro không giới hạn và công cụ chuyển mã cực nhanh.

---

## Cài đặt & Sử dụng
1. Tải file `.zip` phiên bản mới nhất từ [GitHub Releases](https://github.com/tuyennq1001/gox/releases/latest).
2. Giải nén vào thư mục bất kỳ trên máy.
3. Nhấp đúp vào file **`Gox.exe`** để khởi chạy.
4. Chọn `Yes` khi User Account Control (UAC) hỏi để chạy dưới quyền Administrator (khuyến nghị để gõ tốt trong game).
5. Biểu tượng chữ `V` sẽ xuất hiện ở System Tray (khay hệ thống). Nhấp đúp vào biểu tượng để mở bảng điều khiển.

---

## Tự Build từ Mã nguồn
Mã nguồn cho Windows được biên dịch bằng Microsoft Visual Studio 2017 / 2019 / 2022:
1. Mở file `OpenKey.sln` trong thư mục `Sources/Gox/win32/OpenKey`.
2. Chọn cấu hình build `Release | x64` (hoặc `Release | Win32`).
3. Nhấn `Build Solution` (Ctrl + Shift + B).

---

## Ghi nhận & Bản quyền
* Phát triển và duy trì bởi **Terry Nguyen** ([@tuyennq1001](https://github.com/tuyennq1001)).
* Kế thừa nền tảng từ dự án OpenKey của tác giả **Mai Vũ Tuyên**.
* Phát hành theo giấy phép mã nguồn mở **GNU General Public License v3.0**.
