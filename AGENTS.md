# AGENTS & CODING RULES (QUY TẮC VẬN HÀNH & KỸ THUẬT)

Tài liệu này là bộ quy tắc cốt lõi gồm 2 phần rõ rệt:
- **PHẦN 1: NGUYÊN TẮC KỸ THUẬT CHUNG (UNIVERSAL COMMON RULES)**: Bắt buộc tuân thủ trên mọi dự án phần mềm (Web, Mobile, Backend, CLI... bất kể ngôn ngữ). **Giữ nguyên 100% khi copy sang dự án mới hoặc đưa vào ChatGPT/AI tool.**
- **PHẦN 2: QUY TẮC ĐẶC THÙ DỰ ÁN (PROJECT-SPECIFIC RULES)**: Tùy biến theo từng dự án cụ thể. *(Hiện tại cấu hình cho dự án: OpenKey)*. Khi sang dự án mới, chỉ cần thay đổi nội dung phần này.

---

# ==============================================================================
# PHẦN 1: QUY TẮC KỸ THUẬT CHUNG CHO MỌI DỰ ÁN (UNIVERSAL COMMON RULES)
# (Độc lập ngôn ngữ & nền tảng — Tái sử dụng nguyên vẹn cho bất kỳ dự án nào)
# ==============================================================================

## 1. Quy trình Git Branching & Quản lý PR (Git Automation Workflow)
- **Tuyệt đối không commit trực tiếp vào nhánh chính**: Không bao giờ commit lên `main` hoặc `master`.
- **Luôn tạo nhánh riêng biệt trước khi viết code**: Tự động tạo nhánh `feature/<tên-tính-năng>` hoặc `fix/<tên-lỗi>` từ nhánh chính trước khi thực hiện bất kỳ thay đổi nào.
- **Quy trình chuẩn 4 bước**:
  1. Viết code.
  2. Chạy toàn bộ bộ kiểm thử tự động (Unit / Integration Tests) — **PHẢI PASS 100%**.
  3. Chạy build/compile dự án — **PHẢI BUILD THÀNH CÔNG**.
  4. Chờ người dùng xác nhận trải nghiệm thực tế chạy đúng mong đợi ➔ **Mới tiến hành commit**.
- **Tiêu chuẩn Commit/PR**:
  - Tiêu đề tuân theo Conventional Commits (`feat(...)`, `fix(...)`), **tối đa ≤ 72 ký tự**.
  - Nội dung mô tả (Body) **ngắn gọn ≤ 5 dòng**. Nếu cần mô tả chi tiết, ghi ra file riêng và đính kèm link.
- **Chỉ Push & Merge khi được yêu cầu**:
  - Mặc định **không tự ý push** lên remote repository. Chỉ push và tạo PR (`gh pr create`) khi người dùng yêu cầu rõ ràng.
  - Chỉ merge PR (`gh pr merge`) vào nhánh chính khi người dùng trực tiếp xác nhận "OK" hoặc "Duyệt".

---

## 2. An toàn Thực thi Terminal & Script (Terminal Safety)
- **Không viết inline script dài trong `-c`**: Bất kỳ script nào (Bash, Python, Node...) nếu dài quá ~5 dòng, **bắt buộc phải ghi ra file script tạm**, cấp quyền và thực thi file đó, sau đó xóa file tạm đi.
- **Không pipe build output qua bộ lọc chặn (blocking filter)**: Tránh dùng `| grep ...` trực tiếp trên luồng build/compile vì dễ gây treo tiến trình (hang/freeze/timeout) nếu output không khớp pattern.
- **Giới hạn độ dài dòng lệnh**: Mỗi câu lệnh CLI không vượt quá ~2000 ký tự để tránh lỗi buffer overflow và timeout.

---

## 3. Trung thực Dữ liệu & Phê duyệt Trước khi Code (Mandatory Approval)
- **Trung thực dữ liệu tuyệt đối (No Fake / Dummy Data)**: Tuyệt đối không tự ý bịa dữ liệu giả định, tên công ty giả, hoặc nhồi kết quả heuristic giả lập. Mọi dữ liệu hiển thị bắt buộc phải là dữ liệu thật 100% từ API chính thống hoặc nguồn đã kiểm chứng (trừ trường hợp kịch bản mock test được chỉ định rõ).
- **Bắt buộc chờ phê duyệt phương án trước khi sửa code**:
  1. AI phải giải thích nguyên nhân gốc rễ và trình bày phương án kỹ thuật rõ ràng.
  2. **CHỈ TIẾN HÀNH VIẾT CODE KHI NGƯỜI DÙNG XÁC NHẬN "OK" / DUYỆT TRỰC TIẾP** bằng lời nhắn trong chat.
  3. Tuyệt đối không tự động nhảy sang bước viết code / thực thi thay đổi khi người dùng chưa đồng ý.

---

## 4. Tiêu chuẩn Kỹ thuật Hiệu năng (Universal Performance Engineering)
*(Áp dụng cho mọi hệ thống: Frontend UI, Backend API, Mobile, Desktop, CLI)*
- **Cô lập State & Sự kiện tần số cao (State & Event Isolation)**:
  - Các sự kiện hoặc state biến động liên tục (hover chuột, con trỏ, vị trí scroll, sensors, keystrokes input...) **bắt buộc phải cô lập trong component/module con**. Tuyệt đối không đặt ở component cha vì sẽ kích hoạt re-render hoặc re-calculate toàn bộ cây view/component.
- **Cấm tính toán nặng trong Render Loop & Request Hot-Path**:
  - Không chạy sắp xếp (`sort`), lọc mảng lớn (`filter`), parse JSON nặng, hoặc các thuật toán tính toán phức tạp trực tiếp bên trong vòng lặp render giao diện hoặc hàm xử lý request chính.
  - Mọi phép tính nặng phải tính trước (pre-compute) và lưu cache bộ nhớ (in-memory cache / memoization). View/handler chỉ đóng vai trò đọc dữ liệu đã chuẩn bị.
- **Tối ưu cấp phát bộ nhớ & Giảm tải Garbage Collection (Allocation Optimization)**:
  - Tránh khởi tạo các đối tượng tốn kém tài nguyên (date formatters, regex parsers, database connections, crypto engines) lặp đi lặp lại trong vòng lặp kín hoặc từng item của danh sách. Bắt buộc tái sử dụng instance static/singleton hoặc object pool.
- **Ảo hóa & Phân trang dữ liệu lớn (Virtualization & Pagination)**:
  - Trên giao diện: Danh sách lớn bắt buộc phải dùng cơ chế ảo hóa (virtual list/lazy loading), chỉ render các phần tử thực sự nằm trong khung nhìn.
  - Dưới backend/DB: Luôn phân trang (pagination), stream hoặc chunking dữ liệu, tuyệt đối không tải hàng loạt triệu bản ghi vào RAM cùng lúc.
- **Gom cụm & Tiết chế luồng dữ liệu thời gian thực (Buffering & Throttling)**:
  - Dữ liệu từ luồng thời gian thực (WebSocket, Message Queue, Event Stream) không được bắn trực tiếp từng event đơn lẻ lên UI/Main Loop. Bắt buộc có cơ chế buffer gom batch và debounce/throttle (ví dụ: 0.5s – 1.0s) để giảm tải tần suất cập nhật.
- **Bất đồng bộ & Không chặn luồng chính (Non-blocking I/O)**:
  - Mọi thao tác I/O (đọc/ghi file, gọi network, truy vấn DB) tuyệt đối không chạy đồng bộ trên Main Thread / Event Loop chính.
  - Thao tác ghi đĩa/persistence lặp đi lặp lại phải được debounce và đẩy xuống background worker/thread.

---

## 5. Tư duy Triển khai Ngang (Horizontal Deployment Mindset)
Khi giải quyết bất kỳ lỗi hoặc phát triển tính năng nào, bắt buộc tự động rà soát đồng bộ theo 4 trục:
- **Trục Tính năng & Thành phần tương đồng (Feature Parity)**: Nếu sửa/thêm logic ở Module A, phải tự động quét toàn bộ codebase tìm các Module B, C có vai trò hoặc logic tương tự (ví dụ: danh sách chính ↔ danh sách phụ; chế độ xem bảng ↔ chi tiết modal; giỏ hàng ↔ thanh toán) để áp dụng đồng bộ.
- **Trục Đa Nền tảng / Đa Môi trường (Environment & Platform Parity)**: Đảm bảo tính năng hoạt động nhất quán trên mọi nền tảng được hỗ trợ (Desktop ↔ Mobile, Web Responsive, macOS ↔ iOS, Dark Mode ↔ Light Mode).
- **Trục Đầy đủ Trạng thái Dữ liệu (State Parity)**: Mọi thành phần hiển thị/xử lý dữ liệu phải đáp ứng trọn vẹn 4 trạng thái:
  1. `Loading`: Có skeleton/placeholder dự trù, không làm vỡ hoặc giật layout.
  2. `Empty`: Giao diện thông báo trạng thái trống thân thiện, có chỉ dẫn hành động.
  3. `Error`: Bắt lỗi lịch sự, có nút thử lại (Retry), không để crash ứng dụng.
  4. `Loaded`: Hiển thị dữ liệu chính xác.
- **Trục Ổn định Giao diện & Hợp đồng Dữ liệu (Contract & Layout Stability)**:
  - Trên UI: Giữ vững kích thước khung hình, triệt tiêu hiện tượng giật nhảy layout (Zero Layout Shift).
  - Trên Logic: Xử lý triệt để các trường hợp biên (`null/undefined`, chia cho 0 sinh ra `NaN/Inf`, lỗi tràn mảng `Index out of bounds`). Khi thiếu số liệu, hiển thị ký hiệu thay thế lịch sự (`-` hoặc `--`), tuyệt đối không làm crash hay hiển thị giá trị bất thường.

---

## 6. An toàn Concurrency & Kiểm thử Hồi quy (Concurrency & Test Guard)
- **Luồng UI vs Luồng Background**: Mọi cập nhật trạng thái hiển thị người dùng bắt buộc diễn ra trên Main/UI Thread. Mọi tính toán thuật toán nặng hoặc I/O bắt buộc đẩy sang Background Thread/Worker.
- **Kiểm thử hồi quy (Regression Testing Guard)**: Khi sửa đổi các hàm tính toán cốt lõi hoặc thuật toán quan trọng, bắt buộc phải chạy hoặc viết bổ sung Unit Test tương ứng để đảm bảo lỗi không bao giờ tái phát.

---

# ==============================================================================
# PHẦN 2: QUY TẮC ĐẶC THÙ DỰ ÁN (PROJECT-SPECIFIC RULES: GOX)
# ==============================================================================

## 1. An toàn Event Tap & Hiệu năng Hot-Path (Event Tap & CGEventTap Safety)
- **Hàm `OpenKeyCallback` là Hot-Path tối quan trọng**: Hàm này được gọi trên từng sự kiện nhấn phím của toàn bộ hệ điều hành macOS.
- **Cấm I/O đồng bộ & Tính toán nặng trong Callback**: Tuyệt đối không thực hiện đọc/ghi file đĩa, gọi network, cấp phát bộ nhớ động phức tạp, lock dài hạn hoặc sleep bên trong `OpenKeyCallback`. Bất kỳ độ trễ nào cũng sẽ gây đơ/lag con trỏ chuột và bàn phím của toàn hệ thống (hoặc bị macOS tự động vô hiệu hóa tap).
- **Tự động phục hồi khi bị timeout**: Bắt buộc kiểm tra và kích hoạt lại tap (`CGEventTapEnable(..., true)`) khi nhận sự kiện `kCGEventTapDisabledByTimeout`.

---

## 2. Chung sống Hòa bình với Bộ gõ CJK & Ngoại ngữ (Input Source & CJK Bypass)
- **Lắng nghe sự kiện thay vì Polling**: Theo dõi thay đổi bộ gõ qua Notification (`kTISNotifySelectedKeyboardInputSourceChanged` và `NSTextInputContextKeyboardSelectionDidChangeNotification`). Tuyệt đối không gọi đồng bộ `TISCopyCurrentKeyboardInputSource()` trên từng phím gõ.
- **Bypass tuyệt đối cho CJK (Nhật, Hàn, Trung)**: Khi bộ gõ hệ thống đang ở tiếng Nhật (`Japanese`, `Kotoeri`, `GoogleJapaneseInput`), tiếng Hàn (`Korean`, `Hangul`), hoặc tiếng Trung (`SCIM`, `TCIM`, `Pinyin`...), Gox bắt buộc nhả phím nguyên bản (`return event`), không can thiệp, không gửi phím Backspace giả lập làm vỡ bộ đệm tổ hợp inline text.
- **Làm sạch bộ đệm khi chuyển ngữ cảnh**: Luôn gọi `RequestNewSession()` khi đổi bộ gõ hoặc khi chuyển đổi ứng dụng (`activeAppChanged`, `activeSpaceChanged`) để tránh áp dấu tiếng Việt sót lại sang ngữ cảnh mới.

---

## 3. Quản lý Quyền Trợ năng & Vòng đời Khởi động (Accessibility & Lifecycle Guard)
- **Không thoát ứng dụng đột ngột khi thiếu quyền**: Khi chưa được cấp quyền Trợ năng (Accessibility), không gọi `terminate: 0`. Bắt buộc giữ app chạy ngầm, tự động mở trang Cài đặt Trợ năng (`x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility`) và định kỳ thăm dò (`NSTimer` trên `NSRunLoopCommonModes`) để tự động khởi động ngay khi người dùng bật quyền.
- **Định danh Chữ ký mã cố định (Designated Requirement)**: Khi ký mã cục bộ (Ad-hoc Signing), bắt buộc dùng `--requirements '=designated => identifier "com.tuyennq1001.gox"'` để macOS TCC ghi nhận quyền ổn định, không bị mất quyền mỗi lần biên dịch lại binary.
- **Quản lý Login Item & Single Instance an toàn**: Kiểm tra tiến trình đang chạy kỹ lưỡng (`!app.isTerminated && kill(pid, 0) == 0`). Chỉ kích hoạt login item `SMLoginItemSetEnabled` khi file helper thực sự tồn tại trong App Bundle, tránh kích hoạt nhầm helper từ file đĩa DMG gắn tạm.

---

## 4. Tính Toàn vẹn Thuật toán Bộ gõ Tiếng Việt (Vietnamese Engine Integrity)
- **Bảo toàn lõi C++ (Shared Engine)**: Toàn bộ thuật toán phân tích âm tiết, bỏ dấu, gõ tắt và chuyển mã nằm trong `Sources/OpenKey/engine/` được dùng chung giữa macOS và Windows. Mọi sửa đổi phải đảm bảo tính tương thích chéo nền tảng (Cross-platform C++11).
- **Đầy đủ Kiểu gõ & Bảng mã**: Đảm bảo hoạt động chuẩn xác cho tất cả kiểu gõ (Telex, VNI, Simple Telex 1, 2) và bảng mã (Unicode dựng sẵn, TCVN3, VNI Windows, Unicode tổ hợp, CP 1258).
- **Tương thích Trình duyệt & Ô nhập liệu đặc thù**: Tôn trọng và kiểm tra kỹ các cờ tương thích trình duyệt (`vFixRecommendBrowser`, `vFixChromiumBrowser`) để xử lý việc xóa từ gợi ý trên thanh địa chỉ (Omnibox) mượt mà.

---

## 5. Quyền riêng tư & An toàn Tuyệt đối (Zero Telemetry / Keylogger Guard)
- **Bảo vệ dữ liệu bàn phím người dùng 100%**: Gox hoạt động ở tầng hệ thống và nhận mọi keystroke (kể cả mật khẩu, thông tin thẻ tín dụng). Tuyệt đối **không thu thập, không ghi log phím bấm ra file và không gửi bất kỳ dữ liệu nào qua Internet**.
- **Tính năng Check Update an toàn**: Chỉ gửi request kiểm tra phiên bản mới đến endpoint định sẵn, không gửi kèm thông tin nhận dạng người dùng.

---

## 6. Quy tắc Build & Đóng gói macOS (Build & Packaging Rules)
- **Lệnh build chuẩn**: Sử dụng `xcodebuild` với scheme `Gox` trong `Sources/OpenKey/macOS/OpenKey.xcodeproj`.
- **Hỗ trợ Apple Silicon & Intel**: Đảm bảo source code biên dịch sạch trên kiến trúc `arm64` (Apple Silicon) và `x86_64` (Intel).
- **Giữ kho mã nguồn sạch**: Không commit các thư mục build tạm (`build/`, `DerivedData/`, file `.DS_Store`).

---

## 7. Giao diện Menu Bar & Bản địa hóa (UI & Localization)
- **Trạng thái Menu Bar rõ ràng**: Biểu tượng trên thanh trạng thái phải phản ánh chính xác trạng thái Tiếng Việt (`Status`) hoặc Tiếng Anh (`StatusEng`), hỗ trợ template image đổi màu chuẩn theo Light Mode và Dark Mode.
- **Bảo toàn thuật ngữ kỹ thuật**: Giữ nguyên tên các bộ gõ, chuẩn mã hóa và API hệ thống (Telex, VNI, Unicode, TCVN3, Carbon, Event Tap, TIS, Accessibility...).
