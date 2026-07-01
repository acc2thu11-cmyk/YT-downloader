import UIKit
import Social
import MobileCoreServices
import Photos

class ShareViewController: UIViewController {

    // MARK: - UI Elements
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.11, green: 0.12, blue: 0.18, alpha: 0.95) // Dark Slate
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "arrow.down.circle.fill")
        iv.tintColor = UIColor(red: 0.50, green: 0.40, blue: 0.95, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "YT Downloader"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Đang trích xuất liên kết video..."
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.progressTintColor = UIColor(red: 0.50, green: 0.40, blue: 0.95, alpha: 1.0)
        pv.trackTintColor = UIColor.white.withAlphaComponent(0.1)
        pv.layer.cornerRadius = 4
        pv.clipsToBounds = true
        pv.setProgress(0.0, animated: false)
        return pv
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Hủy", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()

    // MARK: - Variables
    private var downloadTask: URLSessionDownloadTask?
    private var activeSession: URLSession?
    private var tempFileURL: URL?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        extractAndProcessURL()
    }
    
    deinit {
        // Xóa file tạm nếu còn tồn tại khi thoát
        cleanupTempFile()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear
        
        // Background blur
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.0
        view.addSubview(blurEffectView)
        
        // Container
        view.addSubview(containerView)
        containerView.addSubview(logoImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(progressView)
        containerView.addSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 240),
            
            logoImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Hoạt ảnh xuất hiện
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.blurEffectView.alpha = 1.0
            self.containerView.transform = .identity
            self.containerView.alpha = 1.0
        }, completion: nil)
    }

    // MARK: - URL Processing
    private func extractAndProcessURL() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            showErrorAndExit("Không tìm thấy dữ liệu chia sẻ.")
            return
        }
        
        let urlType = kUTTypeURL as String
        let textType = kUTTypePlainText as String
        
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(urlType) {
                provider.loadItem(forTypeIdentifier: urlType, options: nil) { [weak self] (item, error) in
                    if let url = item as? URL {
                        self?.fetchDownloadLink(youtubeURL: url.absoluteString)
                    } else if let urlString = item as? String {
                        self?.fetchDownloadLink(youtubeURL: urlString)
                    } else {
                        self?.showErrorAndExit("Không thể phân tích liên kết.")
                    }
                }
                return
            } else if provider.hasItemConformingToTypeIdentifier(textType) {
                provider.loadItem(forTypeIdentifier: textType, options: nil) { [weak self] (item, error) in
                    if let text = item as? String, let urlString = self?.extractURLString(from: text) {
                        self?.fetchDownloadLink(youtubeURL: urlString)
                    } else {
                        self?.showErrorAndExit("Không tìm thấy liên kết YouTube hợp lệ.")
                    }
                }
                return
            }
        }
        
        showErrorAndExit("Không tìm thấy liên kết phù hợp.")
    }
    
    private func extractURLString(from text: String) -> String? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        return matches?.first?.url?.absoluteString
    }
    
    // MARK: - Cobalt API Integration
    private func fetchDownloadLink(youtubeURL: String) {
        updateStatus("Đang phân tích video...")
        
        guard let apiURL = URL(string: "https://api.cobalt.tools/api/json") else {
            showErrorAndExit("Lỗi cấu hình máy chủ.")
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "url": youtubeURL,
            "videoQuality": "720", // Cố định 720p hoặc cao hơn tùy cấu hình
            "downloadMode": "auto"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            showErrorAndExit("Lỗi chuẩn bị dữ liệu.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAndExit("Lỗi mạng: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.showErrorAndExit("Không có dữ liệu phản hồi.")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let status = json["status"] as? String, status == "stream", let downloadURLString = json["url"] as? String {
                        self.downloadVideoFile(urlString: downloadURLString)
                    } else if let errorText = json["text"] as? String {
                        self.showErrorAndExit("Cobalt Error: \(errorText)")
                    } else {
                        self.showErrorAndExit("Lỗi trích xuất video.")
                    }
                } else {
                    self.showErrorAndExit("Dữ liệu phản hồi không đúng định dạng.")
                }
            } catch {
                self.showErrorAndExit("Lỗi giải nén thông tin phản hồi.")
            }
        }
        task.resume()
    }
    
    // MARK: - Video Downloading
    private func downloadVideoFile(urlString: String) {
        guard let url = URL(string: urlString) else {
            showErrorAndExit("Đường dẫn tải video lỗi.")
            return
        }
        
        updateStatus("Bắt đầu tải video...")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.activeSession = session
        
        let task = session.downloadTask(with: url)
        self.downloadTask = task
        task.resume()
    }
    
    // MARK: - Save to Photos
    private func saveToPhotos(tempURL: URL) {
        updateStatus("Đang lưu vào thư viện ảnh...")
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            if status != .authorized && status != .limited {
                self.showErrorAndExit("Ứng dụng chưa được cấp quyền truy cập Thư viện ảnh. Vui lòng mở ứng dụng chính để cấp quyền.")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempURL)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.showSuccessAndExit()
                    } else {
                        self.showErrorAndExit("Không thể lưu video: \(error?.localizedDescription ?? "Lỗi không xác định")")
                    }
                }
            }
        }
    }
    
    // MARK: - Cleanup & Exit
    private func cleanupTempFile() {
        if let tempURL = tempFileURL {
            try? FileManager.default.removeItem(at: tempURL)
            self.tempFileURL = nil
        }
    }
    
    private func updateStatus(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusLabel.text = text
        }
    }
    
    private func showErrorAndExit(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logoImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            self.logoImageView.tintColor = .systemRed
            self.statusLabel.text = message
            self.progressView.isHidden = true
            self.cancelButton.setTitle("Đóng", for: .normal)
            self.cancelButton.setTitleColor(.white, for: .normal)
            self.cancelButton.backgroundColor = .systemRed
            self.cancelButton.layer.cornerRadius = 8
        }
    }
    
    private func showSuccessAndExit() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.logoImageView.image = UIImage(systemName: "checkmark.circle.fill")
            self.logoImageView.tintColor = UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1.0)
            self.statusLabel.text = "Tải thành công! Video đã lưu vào thư viện ảnh."
            self.progressView.setProgress(1.0, animated: true)
            
            // Tự động đóng sau 1.5 giây
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.dismissExtension(completed: true)
            }
        }
    }
    
    private func dismissExtension(completed: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.blurEffectView.alpha = 0.0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView.alpha = 0.0
        }) { _ in
            self.cleanupTempFile()
            if completed {
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            } else {
                self.extensionContext?.cancelRequest(withError: NSError(domain: "UserCancelled", code: 0, userInfo: nil))
            }
        }
    }
    
    @objc private func cancelTapped() {
        downloadTask?.cancel()
        dismissExtension(completed: false)
    }
}

// MARK: - URLSessionDownloadDelegate
extension ShareViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let percent = Int(progress * 100)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.progressView.setProgress(progress, animated: true)
            self.statusLabel.text = "Đang tải video... \(percent)%"
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Vì hệ thống sẽ xóa file tại location sau khi kết thúc hàm này, chúng ta cần copy ra một thư mục tạm của app
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let uniqueFileName = UUID().uuidString + ".mp4"
        let destinationURL = tempDirectory.appendingPathComponent(uniqueFileName)
        
        do {
            // Đảm bảo không trùng tên file
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: location, to: destinationURL)
            self.tempFileURL = destinationURL
            self.saveToPhotos(tempURL: destinationURL)
        } catch {
            showErrorAndExit("Không thể lưu file video tạm.")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            // Không hiển thị lỗi nếu người dùng chủ động bấm Hủy (NSURLErrorCancelled)
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                return
            }
            showErrorAndExit("Lỗi tải file: \(error.localizedDescription)")
        }
    }
}
