# Gox for Linux (Ubuntu / Debian)
[![License: GPLv3](https://img.shields.io/badge/License-GPLv3-green.svg)](https://github.com/tuyennq1001/gox/blob/master/LICENSE)

**Gox for Linux** — Gõ Tiếng Việt & Tiếng Nhật song hành không độ trễ.

---

## Trạng thái phát triển (Official Roadmap)
Phiên bản Gox cho Linux (Ubuntu / Debian và các bản phân phối Linux khác) hiện đang trong **Lộ trình phát triển chính thức**:
* 🎯 **Mục tiêu**: Tích hợp trực tiếp với bộ gõ hệ thống (IBus / Fcitx5) và cung cấp Daemon độc lập chạy qua `uinput` + `evdev`, hỗ trợ đầy đủ cả X11 và Wayland.
* 🇯🇵 **Ưu tiên hàng đầu**: Tương thích mượt mà với Mozc (Japanese IME) — cứ chuyển là gõ, không làm vỡ bộ đệm tổ hợp ký tự inline, không cần cấu hình phức tạp.
* ⚡ **Core Engine**: Tận dụng 100% Shared C++ Engine hiện có trong `Sources/Gox/engine/` (với định nghĩa mã phím trong `platforms/linux.h`).

---

## Đóng góp phát triển
Nếu bạn là lập trình viên Linux C++ / IBus / Fcitx5 / Wayland và quan tâm đến dự án, xin vui lòng theo dõi và đóng góp qua:
* [GitHub Issues](https://github.com/tuyennq1001/gox/issues)
* [GitHub Pull Requests](https://github.com/tuyennq1001/gox/pulls)
