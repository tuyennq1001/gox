<p align="center">
  <img src="assets/logo.png" alt="Gox Logo" width="130" />
</p>

<h1 align="center">Gox — Gõ Tiếng Việt & Tiếng Nhật song hành không độ trễ</h1>

<p align="center">
  <strong>🌟 Bộ gõ Tiếng Việt thế hệ mới đa nền tảng (macOS • Windows • Linux) — Tương thích tuyệt đối với Tiếng Nhật, cứ chuyển là gõ, không cần tắt bộ gõ!</strong>
</p>

<p align="center">
  <a href="https://github.com/tuyennq1001/gox/releases/latest">
    <img src="https://img.shields.io/github/v/release/tuyennq1001/gox.svg?color=blue" alt="Latest Release">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-GPLv3-green.svg" alt="License">
  </a>
  <img src="https://img.shields.io/badge/Platforms-macOS%20%7C%20Windows%20%7C%20Linux-indigo.svg" alt="Platforms">
  <img src="https://img.shields.io/badge/CJK%20Bypass-Zero--Latency-success.svg" alt="CJK Bypass">
  <img src="https://img.shields.io/badge/Keyboard-JIS%20Ready-orange.svg" alt="JIS Keyboard Ready">
  <img src="https://img.shields.io/badge/Privacy-Zero--Telemetry-blue.svg" alt="Zero Telemetry">
</p>

---

## Giới thiệu
**Gox** là bộ gõ tiếng Việt hiện đại, mã nguồn mở, đa nền tảng (**macOS • Windows • Linux**), được tối ưu hóa đặc quyền cho các kỹ sư, BrSE, Comtor, lập trình viên và du học sinh làm việc trong môi trường song ngữ **Việt – Nhật**.

Được xây dựng với triết lý **tối giản, siêu nhẹ, zero-telemetry**, Gox giải quyết triệt để lỗi gạch chân, kẹt phím, đúp chữ trên các trình duyệt hiện đại (Chrome, Safari, Edge) và hoạt động mượt mà trong môi trường phát triển (VS Code, Xcode, Terminal, JetBrains).

> [!IMPORTANT]
> ### 🇯🇵 Trải nghiệm song ngữ Việt – Nhật mượt mà: Không độ trễ, không cần tắt bộ gõ!
> * **Nỗi đau phổ biến**: Trên macOS và Windows, các bộ gõ tiếng Việt thông thường (EVKey, OpenKey, Unikey, GoTiengViet...) đều bắt phím ngầm và gửi phím Backspace giả lập, làm vỡ bộ đệm tổ hợp Romaji ➔ Hiragana/Kanji của IME tiếng Nhật (Kotoeri, Google Japanese Input, Microsoft Japanese IME). Người dùng luôn phải nhớ chuyển bộ gõ sang Tiếng Anh (E) hoặc tắt hẳn trước khi gõ tiếng Nhật.
> * **Giải pháp đột phá của Gox**: Gox tự động theo dõi trạng thái bộ gõ của hệ điều hành. Khi bạn chuyển sang Tiếng Nhật, Gox lập tức kích hoạt cơ chế **Bypass nguyên bản** — phím bấm được chuyển thẳng đến IME tiếng Nhật. **Bạn hoàn toàn không cần tắt Gox, không cần chuyển về Tiếng Anh (E), cứ chuyển đổi ngôn ngữ là gõ được ngay.**

> [!TIP]
> ### ✍️ Loại bỏ lỗi gạch chân khó chịu ở bộ gõ mặc định: Gõ sai không lo phải xóa cả từ!
> * **Nỗi đau ở bộ gõ mặc định**: Trên macOS, bộ gõ tiếng Việt mặc định của Apple sử dụng cơ chế gạch chân (preedit inline buffer). Khi đang gõ, chữ sẽ bị gạch chân bên dưới; ngay khi bạn bấm dấu cách hoặc di chuyển con trỏ, gạch chân biến mất và từ bị chốt cứng (commit). **Hậu quả là nếu lỡ gõ sai, bạn không thể bấm phím sửa dấu hay sửa từng ký tự lẻ mà bắt buộc phải xóa toàn bộ cả từ để gõ lại từ đầu**, vô cùng ức chế và làm gián đoạn dòng gõ phím.
> * **Trải nghiệm tự do cùng Gox**: Gox triệt tiêu hoàn toàn gạch chân phiền toái. Bạn có thể thoải mái sửa phím, lùi từ, bỏ dấu tự do mà không bao giờ phải gõ lại nguyên từ. Đồng thời loại bỏ triệt để hiện tượng kẹt phím, nhảy chữ, đúp từ trên thanh địa chỉ trình duyệt (Chrome, Safari Omnibox) và các trình biên soạn mã nguồn (VS Code, Xcode).

> [!NOTE]
> ### 🛡️ Mã nguồn mở 100% & Zero-Telemetry: Không lo Keylogger như các phần mềm nguồn đóng!
> * **Mối lo từ bộ gõ nguồn đóng**: Bộ gõ là phần mềm nhạy cảm nhất vì nhận trọn vẹn mọi ký tự bạn gõ trên bàn phím — từ mật khẩu tài khoản, mã PIN ngân hàng, tin nhắn riêng tư đến mã nguồn bảo mật của công ty. Các bộ gõ nguồn đóng tiềm ẩn rủi ro bị cài cắm keylogger ngầm hoặc âm thầm thu thập hành vi người dùng gửi về máy chủ mà không ai kiểm chứng được.
> * **Cam kết minh bạch tuyệt đối của Gox**: Gox là phần mềm **mã nguồn mở 100% (GPLv3)**, hoạt động **hoàn toàn offline** và cam kết **Zero-Telemetry (không thu thập bất kỳ dữ liệu nào)**. Toàn bộ mã nguồn được công khai trên GitHub, mang lại sự an tâm tuyệt đối cho người dùng cá nhân lẫn các kỹ sư làm việc trong môi trường doanh nghiệp khắt khe về an toàn thông tin.

---

### Điểm nổi bật:
* 🇯🇵 **Dùng song song Tiếng Nhật (Không cần tắt Gox)**: Thoải mái gõ tiếng Nhật (Kotoeri, Google Japanese Input, Microsoft IME...) song song với tiếng Việt 24/7. Tự động nhận diện và bypass phím bấm nguyên bản, không làm vỡ bộ đệm tổ hợp Romaji/Hiragana/Kanji.
* ✍️ **Xóa bỏ lỗi gạch chân khó chịu**: Khắc phục triệt để nhược điểm của bộ gõ mặc định. Lỡ gõ sai có thể sửa ngay tại chỗ, không bao giờ phải xóa cả từ để gõ lại.
* 🛡️ **Mã nguồn mở & Không lo Keylogger**: 100% mã nguồn mở minh bạch, hoàn toàn offline, zero telemetry. An toàn tuyệt đối cho mật khẩu và dữ liệu công việc so với các phần mềm nguồn đóng.
* 💖 **Miễn phí trọn đời & Luôn cập nhật**: Dự án phi lợi nhuận vì cộng đồng, tích hợp tính năng cập nhật 1-click tức thì (In-App Auto-Update), liên tục bảo trì và phát triển bền vững.
* ⌨️ **Tương thích hoàn hảo Bàn phím chuẩn Nhật (JIS Keyboard)**: Chuyển đổi mượt mà với các phím đặc thù trên bàn phím JIS (`かな` / `英数`) cũng như bàn phím US/quốc tế (`Ctrl + Space`, `Globe/Fn`).
* 💻 **Hỗ trợ Đa nền tảng (Cross-Platform)**: Trải nghiệm nhất quán trên cả **macOS** và **Windows**, cùng lộ trình tích hợp sâu cho **Linux (Ubuntu/Debian)**.
* 🚀 **Siêu nhẹ & Hiệu năng cao**: Hot-path xử lý phím bấm được tối ưu triệt để bằng C++, không gây lag con trỏ hay đơ bàn phím.
* 🔄 **Chuyển chế độ thông minh**: Tự ghi nhớ chế độ Tiếng Việt/Tiếng Anh theo từng ứng dụng (Safari/Browser ↔ Terminal/IDE).
* 🎯 **Khắc phục lỗi gõ trên Browser**: Tích hợp cơ chế sửa lỗi đúp từ trên Omnibox trình duyệt Chromium, Safari, Edge.

---

## Tình trạng hỗ trợ Nền tảng (Platform Support)

| Nền tảng | Trạng thái | Điểm nhấn kỹ thuật |
| :--- | :---: | :--- |
| 🍏 **macOS** | **Sẵn sàng (Stable)** | Chạy native Apple Silicon (M1/M2/M3/M4) & Intel. Tự động bypass Kotoeri/Google Japanese Input qua TIS notification. |
| 🪟 **Windows** | **Sẵn sàng (Stable)** | Tương thích Windows 10/11 x64. Nhận diện trạng thái IME qua `ImmGetDefaultIMEWnd` + `IMC_GETOPENSTATUS`. Chạy quyền Admin gõ mượt trong game và app đồ họa. |
| 🐧 **Linux (Ubuntu / Debian)** | **Lộ trình (Roadmap)** | Đang phát triển tích hợp IBus/Fcitx5 và standalone daemon dựa trên lõi C++ Engine. |

---

## 🇯🇵 日本語での概要 (About Gox in Japanese)

### Gox — ベトナム語・日本語入力のシームレスな共存を実現する次世代入力アプリ

**Gox** は、macOS および Windows に対応したオープンソースのベトナム語入力アプリです。特に日越のバイリンガル環境で活躍するエンジニア、BrSE、通訳・翻訳者、留学生のために設計されています。

#### 主な特徴:
1. **日本語IMEとの完全な共存（遅延ゼロ・バッファ破損なし）**:
   * 従来のベトナム語入力ソフトでは、日本語入力時にインライン変換バッファ（ローマ字 ➔ ひらがな/漢字）が破壊される問題がありました。
   * Gox はOSの入力ソース状態を自動検出し、日本語（ことえり、Google日本語入力、Microsoft IME）が選択された瞬間に**キーストロークをそのまま通過（Bypass）**させます。ベトナム語入力をオフにする必要は一切ありません。
2. **煩わしい「下線（インライン変換）」を完全排除**:
   * macOS標準のベトナム語入力のように下線で入力中テキストが固定されることがなく、入力ミス時にも単語全体を消去せずその場で柔軟に修正可能です。
3. **100% オープンソース＆キーロガーの心配ゼロ（Zero-Telemetry）**:
   * クローズドソース（ソース非公開）の入力ソフトとは異なり、Goxはソースコードを完全公開（GPLv3）し、完全オフラインで動作します。キーストロークの収集や外部送信は一切行わないため、企業の機密情報やパスワードの入力も極めて安全です。
4. **JIS配列キーボード完全対応**:
   * 日本語キーボード（JIS）特有の「かな」「英数」キーや、macOSの「Caps Lock / 地球儀キー」での切り替えにスムーズに対応。
5. **超軽量＆高パフォーマンス＆継続的なアップデート**:
   * C++で極限まで最適化されたコアエンジンにより、遅延ゼロの高速タイピングを実現。メニューバーからの1クリック自動更新に対応し、常に最新の状態で安心してご利用いただけます。

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

## Cài đặt & Sử dụng

### 1. Dành cho macOS
1. Tải file cài đặt `.dmg` bản mới nhất: [Tải trực tiếp Gox.dmg](https://github.com/tuyennq1001/gox/releases/latest/download/Gox.dmg) (hoặc xem tại [GitHub Releases](https://github.com/tuyennq1001/gox/releases/latest)).
2. Mở file `.dmg` và kéo biểu tượng **`Gox.app`** vào thư mục **`Applications`**.
3. **Mở ứng dụng lần đầu (Bỏ qua cảnh báo Gatekeeper)**:
   - Do Gox là phần mềm nguồn mở miễn phí, macOS sẽ yêu cầu xác nhận khi mở lần đầu.
   - Nhấp **chuột phải (hoặc giữ phím Control + click)** vào `Gox.app` trong thư mục `Applications` ➔ Chọn **Mở (Open)** ➔ Chọn tiếp **Mở (Open)** ở hộp thoại xác nhận.
4. **Cấp quyền Trợ năng (Accessibility)**:
   - Vào **Cài đặt hệ thống (System Settings)** ➔ **Quyền riêng tư & Bảo mật (Privacy & Security)** ➔ **Trợ năng (Accessibility)** ➔ Bật công tắc cho **`Gox`**.

> [!TIP]
> **Dành cho người dùng tiếng Nhật trên macOS**:
> Bạn có thể thoải mái chuyển đổi giữa Tiếng Nhật và Tiếng Việt bằng phím tắt hệ thống thông thường (`Control + Space`, phím `Globe/Fn` hoặc phím `かな/英数` trên bàn phím JIS). Gox tự động phát hiện và bypass hoàn toàn — **tuyệt đối không cần phải tắt Gox hay chuyển về Tiếng Anh thủ công**.

### 2. Dành cho Windows
1. Tải file `.zip` bản mới nhất từ [GitHub Releases](https://github.com/tuyennq1001/gox/releases/latest).
2. Giải nén vào thư mục bất kỳ và chạy file **`Gox.exe`**.
3. Khuyến nghị chạy dưới quyền **Administrator** (có sẵn tùy chọn trong phần Cài đặt) để gõ tốt trong game và các phần mềm đồ họa (Photoshop, CAD...).

---

## Tự Build từ Mã nguồn

### macOS:
Yêu cầu macOS 10.14 trở lên và Xcode 11 trở lên:
```bash
git clone https://github.com/tuyennq1001/gox.git
cd gox
xcodebuild -project Sources/Gox/macOS/Gox.xcodeproj -scheme Gox build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

### Windows:
Mở giải pháp `Sources/Gox/win32/OpenKey/OpenKey.sln` bằng Visual Studio 2017/2019/2022 và chọn cấu hình `Release | x64` để biên dịch.

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
