<p align="center">
  <img src="assets/logo.png" alt="Gox Logo" width="130" />
</p>

<h1 align="center">Gox — Bộ gõ Tiếng Việt Native cho macOS</h1>

<p align="center">
  <strong>🌟 Gõ Tiếng Việt & Tiếng Nhật song hành không độ trễ — Tương thích tuyệt đối Bàn phím Nhật JIS (かな / 英数)</strong>
</p>

<p align="center">
  <a href="https://github.com/tuyennq1001/gox/releases/latest">
    <img src="https://img.shields.io/github/v/release/tuyennq1001/gox.svg?color=blue" alt="Latest Release">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-GPLv3-green.svg" alt="License">
  </a>
  <img src="https://img.shields.io/badge/macOS-12.0%2B%20(Apple%20Silicon%20%26%20Intel)-indigo.svg" alt="macOS 12.0+">
  <img src="https://img.shields.io/badge/Apple-Notarized-success.svg" alt="Apple Notarized">
  <img src="https://img.shields.io/badge/CJK%20Bypass-Zero--Latency-success.svg" alt="CJK Bypass">
  <img src="https://img.shields.io/badge/Keyboard-JIS%20Ready%20(%E3%81%8B%E3%81%AA%2F%E8%8B%B1%E6%95%B0)-orange.svg" alt="JIS Keyboard Ready">
  <img src="https://img.shields.io/badge/Privacy-Zero--Telemetry-blue.svg" alt="Zero Telemetry">
</p>

---

## Giới thiệu
**Gox** là bộ gõ tiếng Việt Native hiện đại, mã nguồn mở, được tối ưu hóa đặc quyền cho **macOS** (tương thích 100% chip Apple Silicon M1/M2/M3/M4 & Intel). Ứng dụng được thiết kế riêng cho các kỹ sư, BrSE, Comtor, lập trình viên và du học sinh làm việc trong môi trường song ngữ **Việt – Nhật** hoặc sử dụng **MacBook bàn phím Nhật (JIS Layout)**.

Được xây dựng với triết lý **tối giản, siêu nhẹ, zero-telemetry**, Gox giải quyết triệt để lỗi gạch chân, kẹt phím, đúp chữ trên các trình duyệt hiện đại (Chrome, Safari, Edge) và hoạt động mượt mà trong môi trường phát triển (VS Code, Xcode, Terminal, JetBrains, Meta Muse).

> [!IMPORTANT]
> ### 🇯🇵 Đặc quyền Bàn phím Nhật (JIS Layout) & Phím `かな` / `英数`: Không trôi chữ, không cần tắt bộ gõ!
> * **Nỗi đau phổ biến trên MacBook xách tay Nhật & công ty cấp**:
>   1. **Trôi chữ thô khó chịu**: Khi vừa bấm phím `かな` (104) hoặc `英数` (102) để chuyển chế độ rồi quay lại gõ tiếng Việt, các bộ gõ cũ bị lỗi nhét mã phím vào buffer gây trôi chữ thô dị dạng (`khacsh`, `seeps`, `neeus`, `vaayj`).
>   2. **Vỡ bộ đệm tổ hợp tiếng Nhật**: Các bộ gõ tiếng Việt thông thường gửi phím Backspace giả lập làm vỡ cụm Romaji ➔ Hiragana/Kanji (`とうきょう`). Người dùng luôn phải nhớ tắt bộ gõ thủ công mỗi khi gõ tiếng Nhật.
>   3. **Lỗi gõ phím `@` thành chữ `ơ`**: Do layout JIS đặt `@` ở keycode 33 (vốn là phím `[` trên bàn phím US).
> * **Giải pháp đột phá của Gox**:
>   - Gox tự động bắt phím `かな` và `英数` trước bộ lọc hệ thống, tự động làm sạch buffer từ ngay tức khắc: **Chấm dứt hoàn toàn hiện tượng trôi chữ thô**.
>   - **Tự động chuyển đổi thông minh**: Bấm `かな` ➔ Gox tự động **Bypass 100%** nhả phím nguyên bản cho IME tiếng Nhật (Kotoeri, Google Japanese Input); Bấm `英数` ➔ Gox tự động **kích hoạt lại Tiếng Việt** ngay lập tức. **Tuyệt đối không cần tắt Gox thủ công, không cần đụng chuột lên Menu Bar.**
>   - Nhận diện phần cứng JIS qua API native macOS, giữ nguyên phím `@` khi gõ email và ánh xạ chuẩn xác `[` / `]` sang `ơ` / `ư`.

> [!TIP]
> ### ✍️ Loại bỏ lỗi gạch chân khó chịu ở bộ gõ mặc định: Gõ sai không lo phải xóa cả từ!
> * **Nỗi đau ở bộ gõ mặc định**: Trên macOS, bộ gõ tiếng Việt mặc định của Apple sử dụng cơ chế gạch chân (preedit inline buffer). Khi gõ sai, bạn không thể bấm phím sửa dấu hay sửa từng ký tự lẻ mà bắt buộc phải xóa toàn bộ cả từ để gõ lại từ đầu, vô cùng ức chế và làm gián đoạn dòng suy nghĩ.
> * **Trải nghiệm tự do cùng Gox**: Gox triệt tiêu hoàn toàn gạch chân phiền toái. Bạn có thể thoải mái sửa phím, lùi từ, bỏ dấu tự do mà không bao giờ phải gõ lại nguyên từ. Đồng thời loại bỏ triệt để hiện tượng kẹt phím, nhảy chữ, đúp từ trên thanh địa chỉ trình duyệt (Chrome, Safari Omnibox), các IDE (VS Code, Xcode) và ứng dụng ghi chú Meta Muse.

> [!WARNING]
> ### 🚨 Cảnh báo trực quan khóa phím Secure Input (v1.0.11): Không còn cảnh tưởng bộ gõ bị đơ!
> * **Hiện tượng**: Thỉnh thoảng đang gõ tiếng Việt bình thường thì bộ gõ đột ngột mất tác dụng, chỉ gõ được chữ tiếng Anh không dấu. Nguyên nhân thực chất là do một tab trình duyệt ẩn hoặc ứng dụng (Chrome, Safari, 1Password...) đang kích hoạt ô mật khẩu và khóa bàn phím toàn hệ thống (Secure Event Input).
> * **Tính năng độc quyền của Gox**: Truy vấn trực tiếp Kernel `IORegistry` (`IOConsoleUsers`), nhận diện chuẩn xác ứng dụng đang khóa bàn phím. Logo chữ **`V`** trên Menu Bar sẽ **nhấp nháy đỏ 3 lần và chuyển sang màu ĐỎ rực** cảnh báo. Người dùng chỉ cần **1-Click vào dòng thông báo trên Menu Bar** để đưa ngay ứng dụng khóa phím lên trước màn hình để thoát ô mật khẩu nhanh chóng!

> [!NOTE]
> ### 🛡️ Mã nguồn mở 100%, Zero-Telemetry & Đã được Apple công chứng (Apple Notarized)
> * **Mối lo từ bộ gõ nguồn đóng**: Bộ gõ là phần mềm nhạy cảm nhất vì nhận trọn vẹn mọi phím bấm — mật khẩu tài khoản, mã PIN ngân hàng, tin nhắn riêng tư và source code công ty. Các bộ gõ nguồn đóng tiềm ẩn rủi ro cài cắm keylogger gửi dữ liệu về máy chủ.
> * **Cam kết minh bạch tuyệt đối của Gox**: Gox là phần mềm **mã nguồn mở 100% (GPLv3)**, hoạt động **hoàn toàn offline** và cam kết **Zero-Telemetry**. Binary `Gox.app` và gói cài đặt `Gox.dmg` đã được **ký số Apple Developer ID và công chứng chính thức (Apple Notarized)**, kèm tính năng **Tự động Cập nhật 1-Click (In-App Auto-Update)** trực tiếp trên Menu Bar mà không bao giờ làm mất quyền Trợ năng (Accessibility).

---

### Điểm nổi bật:
* ⌨️ **Tương thích hoàn hảo Bàn phím chuẩn Nhật (JIS Layout)**: Hỗ trợ mượt mà phím `かな` / `英数`, gõ chuẩn phím `@`, diệt tận gốc lỗi trôi chữ thô `khacsh`, `vaayj`.
* 🇯🇵 **Dùng song song Tiếng Nhật (Không cần tắt Gox)**: Tự động nhận diện và bypass phím bấm nguyên bản khi gõ Kotoeri hay Google Japanese Input, không làm vỡ bộ đệm Romaji ➔ Kanji.
* 🚨 **Cảnh báo đỏ Secure Input & 1-Click xử lý**: Menu Bar nháy đỏ cảnh báo khi bị ô mật khẩu khóa phím, click để nhảy ngay đến app thủ phạm.
* ✍️ **Xóa bỏ lỗi gạch chân khó chịu**: Không bao giờ phải xóa cả từ để gõ lại dấu; triệt tiêu lỗi đúp từ trên thanh địa chỉ Chrome, Safari và Meta Muse.
* 🛡️ **Mã nguồn mở GPLv3 & Apple Notarized**: Không lo Keylogger, an toàn tuyệt đối cho doanh nghiệp, mở trực tiếp mượt mà không bị Gatekeeper chặn.
* 💖 **Tự động Cập nhật 1-Click (In-App Update)**: Kiểm tra và nâng cấp phiên bản mới chỉ với 1 cú click ngay trên Menu Bar.
* 🚀 **Siêu nhẹ & Hiệu năng cao**: Viết bằng Objective-C/C++ tối ưu ở tầng `CGEventTap`, tự phục hồi khi hệ thống lag timeout, tiêu thụ 0% CPU lúc nghỉ.
* 🔄 **Chuyển chế độ thông minh**: Tự ghi nhớ chế độ Tiếng Việt / Tiếng Anh cho từng phần mềm (Safari ↔ Terminal/IDE).

---

## 🇯🇵 日本語での概要 (About Gox in Japanese)

### Gox — macOS専用・ベトナム語と日本語入力のシームレスな共存を実現する次世代入力アプリ

**Gox** は、macOS（Apple Silicon M1〜M4 & Intel）にネイティブ対応したオープンソースのベトナム語入力アプリです。特に日越のバイリンガル環境で活躍するエンジニア、BrSE、通訳・翻訳者、留学生、および**JIS配列（日本語キーボード）のMacBook**をご利用の方のために極限まで最適化されています。

#### 主な特徴:
1. **JIS配列キーボード（「かな」「英数」キー）完全対応**:
   * 「かな」(104)・「英数」(102)キーを押した直後の入力バッファ破損（`khacsh`, `vaayj` のような未変換ゴミ文字の発生）を根本から解消。
   * 「かな」キーで日本語IMEへ100%自動パススルー、「英数」キーで即座にベトナム語入力を復帰。Goxを手動でオン/オフする必要はありません。
   * 日本語配列特有の「@」キー誤変換（「ơ」になる問題）を完全修正。
2. **煩わしい「下線（インライン変換）」を完全排除**:
   * macOS標準のベトナム語入力のような下線固定がなく、入力ミス時にも単語全体を消去せずその場で柔軟に修正可能です。Chrome/SafariのアドレスバーやMeta Museでの二重入力バグも解消。
3. **セキュア入力（Secure Input）の視覚的赤色警告（v1.0.11新機能）**:
   * パスワード入力欄等によりキー入力がロックされた場合、メニューバーの「V」アイコンが赤く3回点滅し、鮮やかな赤色に変化。メニューをクリックするだけでロック元のアプリを最前面に呼び出して素早く解除できます。
4. **100% オープンソース＆Apple公証済み（Zero-Telemetry）**:
   * 完全オープンソース（GPLv3）かつ完全オフライン動作。キーロガーの危険性が一切ありません。
   * Apple Developer IDによる署名と公証（Apple Notarized）を取得済み。Gatekeeperにブロックされることなく安全に起動でき、メニューバーからの1クリック自動更新に対応しています。

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

## Cài đặt & Sử dụng cho macOS

1. Tải file cài đặt `.dmg` bản mới nhất: **[Tải trực tiếp Gox.dmg](https://github.com/tuyennq1001/gox/releases/latest/download/Gox.dmg)** (hoặc xem tại [GitHub Releases](https://github.com/tuyennq1001/gox/releases/latest)).
2. Mở file `.dmg` và kéo biểu tượng **`Gox.app`** vào thư mục **`Applications`**.
3. **Cấp quyền Trợ năng (Accessibility)**:
   - Mở Gox lần đầu, hệ thống sẽ hiển thị yêu cầu cấp quyền Trợ năng.
   - Nhấn **Mở Cài đặt hệ thống (Open System Settings)** ➔ **Quyền riêng tư & Bảo mật (Privacy & Security)** ➔ **Trợ năng (Accessibility)** ➔ Bật công tắc cho **`Gox`**.
   - Bộ gõ sẽ tự động kích hoạt ngay lập tức mà không cần khởi động lại.

> [!TIP]
> **Phím tắt chuyển đổi chế độ gõ**:
> - **Chuyển giữa Tiếng Việt và Tiếng Anh trong Gox**: Mặc định là **`⌥Z`** (Option + Z), có thể tùy chỉnh thành `⌃Space`, `⌥⇧Z` trong Bảng điều khiển.
> - **Khi gõ Tiếng Nhật**: Bạn chỉ cần bấm phím **`かな`** / **`英数`** trên bàn phím JIS hoặc phím chuyển ngôn ngữ hệ thống macOS thông thường (`⌃Space` / `Globe`). Gox tự động nhận diện và bypass — **tuyệt đối không cần tắt Gox thủ công**.

---

## Tự Build từ Mã nguồn

Yêu cầu: macOS 12.0 Monterey trở lên và Xcode 13 trở lên.
```bash
git clone https://github.com/tuyennq1001/gox.git
cd gox
xcodebuild -project Sources/Gox/macOS/Gox.xcodeproj -scheme Gox -configuration Release build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO MACOSX_DEPLOYMENT_TARGET=12.0 -derivedDataPath build/DerivedData
```
File ứng dụng `Gox.app` sẽ được tạo tại `build/DerivedData/Build/Products/Release/Gox.app`. Để tự đóng gói file cài đặt DMG chuẩn giao diện kéo thả, chạy:
```bash
./scripts/package_dmg.sh
```

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
