# iOS YouTube Downloader via Share Extension

Đây là dự án ứng dụng iOS được thiết kế để xuất hiện trong bảng Chia sẻ (Share Sheet) của iOS (đặc biệt là ứng dụng YouTube) khi bạn bấm "Chia sẻ" trên một video, tự động tải xuống video đó dưới dạng file MP4 chất lượng cao và lưu thẳng vào **Thư viện ảnh (Photo Library)** trên iPhone.

Dự án này sử dụng API của **Cobalt** để giải nén liên kết tải video YouTube một cách nhanh chóng và an toàn.

---

## Cấu trúc thư mục mã nguồn

```text
ios-youtube-downloader/
├── README.md                           # Hướng dẫn cài đặt và sử dụng
├── YTDownloader/                       # Mã nguồn ứng dụng chính (Host App)
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── MainViewController.swift
│   └── Info.plist
└── YTShareExtension/                   # Mã nguồn Share Extension
    ├── ShareViewController.swift
    └── Info.plist
```

---

## Hướng dẫn thiết lập Xcode trên máy macOS

Vì bạn đang phát triển trên môi trường Windows, sau khi tải các file này về, hãy chuyển chúng lên một máy **macOS** chạy Xcode để thực hiện các bước sau:

### Bước 1: Tạo Xcode Project mới
1. Mở Xcode, chọn **File > New > Project**.
2. Chọn **iOS > App** và click **Next**.
3. Điền thông tin:
   - **Product Name**: `YTDownloader`
   - **Organization Identifier**: Ví dụ `com.yourname`
   - **Interface**: Chọn **Storyboard**
   - **Language**: Chọn **Swift**
4. Click **Next** và lưu dự án vào một thư mục.

### Bước 2: Thêm Share Extension Target
1. Trong Xcode, chọn **File > New > Target**.
2. Chọn **iOS > Share Extension** (nằm trong mục Application Extension) rồi click **Next**.
3. Điền thông tin:
   - **Product Name**: `YTShareExtension`
   - Click **Finish**.
4. Khi Xcode hỏi có muốn kích hoạt (Activate) scheme cho Extension không, hãy chọn **Activate**.

### Bước 3: Import mã nguồn Swift & Cấu hình `Info.plist`
Thay thế các file mặc định do Xcode tự sinh bằng mã nguồn đã được tạo sẵn trong thư mục này:

1. **Đối với ứng dụng chính (`YTDownloader`)**:
   - Thay thế nội dung file `AppDelegate.swift`, `SceneDelegate.swift`, `ViewController.swift` (hoặc tạo file mới `MainViewController.swift` và cấu hình Main Storyboard trỏ class vào nó).
   - Mở file `Info.plist` của app chính và thêm các quyền sau để xin phép lưu ảnh/video:
     - `Privacy - Photo Library Additions Usage Description` -> `Ứng dụng cần quyền ghi để lưu video vào thư viện ảnh.`
     - `Privacy - Photo Library Usage Description` -> `Ứng dụng cần quyền đọc/ghi để lưu video vào thư viện ảnh.`

2. **Đối với Extension (`YTShareExtension`)**:
   - Thay thế nội dung file `ShareViewController.swift`.
   - Mở file `Info.plist` của extension và tìm đến khóa `NSExtension`. Thay đổi nội dung của nó để chỉ định loại dữ liệu đầu vào được chấp nhận (chỉ nhận URL hoặc Text có chứa URL):
     ```xml
     <key>NSExtension</key>
     <dict>
         <key>NSExtensionAttributes</key>
         <dict>
             <key>NSExtensionActivationRule</key>
             <string>SUBQUERY (
                 extensionItems,
                 $extensionItem,
                 SUBQUERY (
                     $extensionItem.attachments,
                     $attachment,
                     ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.url"
                     OR ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.plain-text"
                 ).@count &gt; 0
             ).@count &gt; 0</string>
         </dict>
         <key>NSExtensionPointIdentifier</key>
         <string>com.apple.share-services</string>
         <key>NSExtensionPrincipalClass</key>
         <string>$(PRODUCT_MODULE_NAME).ShareViewController</string>
     </dict>
     ```

### Bước 4: Chạy thử và trải nghiệm trên iPhone
1. Cắm iPhone của bạn vào máy Mac bằng cáp USB.
2. Chọn Target chính `YTDownloader` và chọn thiết bị của bạn làm thiết bị chạy.
3. Chọn tài khoản Apple Developer của bạn trong tab **Signing & Capabilities** cho cả 2 target (`YTDownloader` và `YTShareExtension`).
4. Nhấn nút **Play / Run** để cài đặt ứng dụng chính lên iPhone.
5. Mở ứng dụng chính trên iPhone một lần và bấm nút **"Cấp quyền truy cập Ảnh"** để cho phép lưu video.
6. Mở ứng dụng **YouTube** -> Tìm một video -> Bấm **Chia sẻ** -> Chọn **Thêm (More)** -> Bật **YTShareExtension** (hoặc chọn nó từ danh sách).
7. Tiến trình tải xuống sẽ xuất hiện ngay trong cửa sổ nhỏ của Share Extension, và khi hoàn tất, video sẽ tự động được lưu vào ứng dụng **Ảnh** của bạn!
