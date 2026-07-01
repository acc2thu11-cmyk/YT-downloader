import UIKit
import Photos

class MainViewController: UIViewController {

    // MARK: - UI Components
    private let gradientLayer = CAGradientLayer()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "square.and.arrow.down.on.square.fill")
        imageView.tintColor = UIColor(red: 0.50, green: 0.40, blue: 0.95, alpha: 1.0) // Violet
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "YT Downloader"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tải video trực tiếp từ ứng dụng YouTube thông qua menu Chia sẻ"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let permissionCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        return view
    }()
    
    private let statusIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.backgroundColor = .systemGray
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Đang kiểm tra quyền thư viện ảnh..."
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let permissionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("CẤP QUYỀN TRUY CẬP ẢNH", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.38, green: 0.35, blue: 0.93, alpha: 1.0) // Indigo
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor(red: 0.38, green: 0.35, blue: 0.93, alpha: 0.4).cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        return button
    }()
    
    private let guideCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()
    
    private let guideTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "HƯỚNG DẪN SỬ DỤNG"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIColor(red: 0.50, green: 0.45, blue: 0.95, alpha: 1.0)
        label.textAlignment = .left
        return label
    }()
    
    private let stepsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupLayout()
        setupActions()
        checkPermissionStatus()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0).cgColor, // Slate 900
            UIColor(red: 0.12, green: 0.11, blue: 0.29, alpha: 1.0).cgColor  // Indigo 950
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupLayout() {
        view.addSubview(headerImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(permissionCard)
        
        permissionCard.addSubview(statusIndicator)
        permissionCard.addSubview(statusLabel)
        permissionCard.addSubview(permissionButton)
        
        view.addSubview(guideCard)
        guideCard.addSubview(guideTitle)
        guideCard.addSubview(stepsStackView)
        
        // Setup Steps
        let step1 = createGuideStep(num: "1", text: "Mở ứng dụng YouTube và chọn video bất kỳ bạn muốn tải.")
        let step2 = createGuideStep(num: "2", text: "Bấm vào nút 'Chia sẻ' dưới video, kéo tìm ứng dụng 'YTDownloader' (nếu không thấy, bấm nút 'Thêm/Khác' ở cuối danh sách).")
        let step3 = createGuideStep(num: "3", text: "Ứng dụng sẽ tự động tải và lưu trực tiếp video vào album Ảnh của bạn.")
        
        stepsStackView.addArrangedSubview(step1)
        stepsStackView.addArrangedSubview(step2)
        stepsStackView.addArrangedSubview(step3)
        
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            headerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 80),
            headerImageView.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Permission Card
            permissionCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            permissionCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            permissionCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            permissionCard.heightAnchor.constraint(equalToConstant: 120),
            
            statusIndicator.leadingAnchor.constraint(equalTo: permissionCard.leadingAnchor, constant: 20),
            statusIndicator.topAnchor.constraint(equalTo: permissionCard.topAnchor, constant: 22),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            statusLabel.centerYAnchor.constraint(equalTo: statusIndicator.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: permissionCard.trailingAnchor, constant: -20),
            
            permissionButton.leadingAnchor.constraint(equalTo: permissionCard.leadingAnchor, constant: 20),
            permissionButton.trailingAnchor.constraint(equalTo: permissionCard.trailingAnchor, constant: -20),
            permissionButton.bottomAnchor.constraint(equalTo: permissionCard.bottomAnchor, constant: -16),
            permissionButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Guide Card
            guideCard.topAnchor.constraint(equalTo: permissionCard.bottomAnchor, constant: 24),
            guideCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            guideCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            guideCard.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            
            guideTitle.topAnchor.constraint(equalTo: guideCard.topAnchor, constant: 20),
            guideTitle.leadingAnchor.constraint(equalTo: guideCard.leadingAnchor, constant: 20),
            guideTitle.trailingAnchor.constraint(equalTo: guideCard.trailingAnchor, constant: -20),
            
            stepsStackView.topAnchor.constraint(equalTo: guideTitle.bottomAnchor, constant: 16),
            stepsStackView.leadingAnchor.constraint(equalTo: guideCard.leadingAnchor, constant: 20),
            stepsStackView.trailingAnchor.constraint(equalTo: guideCard.trailingAnchor, constant: -20),
            stepsStackView.bottomAnchor.constraint(equalTo: guideCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func createGuideStep(num: String, text: String) -> UIView {
        let stepView = UIView()
        
        let numLabel = UILabel()
        numLabel.translatesAutoresizingMaskIntoConstraints = false
        numLabel.text = num
        numLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        numLabel.textColor = .white
        numLabel.textAlignment = .center
        numLabel.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        numLabel.layer.cornerRadius = 10
        numLabel.clipsToBounds = true
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        textLabel.numberOfLines = 0
        
        stepView.addSubview(numLabel)
        stepView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            numLabel.leadingAnchor.constraint(equalTo: stepView.leadingAnchor),
            numLabel.topAnchor.constraint(equalTo: stepView.topAnchor, constant: 2),
            numLabel.widthAnchor.constraint(equalToConstant: 20),
            numLabel.heightAnchor.constraint(equalToConstant: 20),
            
            textLabel.leadingAnchor.constraint(equalTo: numLabel.trailingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: stepView.trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: stepView.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: stepView.bottomAnchor)
        ])
        
        return stepView
    }
    
    private func setupActions() {
        permissionButton.addTarget(self, action: #selector(permissionButtonTapped), for: .touchUpInside)
        permissionButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        permissionButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // MARK: - Actions & Logic
    private func checkPermissionStatus() {
        let status = PHPhotoLibrary.authorizationStatus()
        updateUI(for: status)
    }
    
    private func updateUI(for status: PHAuthorizationStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch status {
            case .authorized, .limited:
                self.statusIndicator.backgroundColor = UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1.0) // Green
                self.statusLabel.text = "Đã có quyền truy cập Thư viện ảnh!"
                self.permissionButton.isEnabled = false
                self.permissionButton.alpha = 0.5
                self.permissionButton.setTitle("QUYỀN HẠN ĐÃ ĐƯỢC CẤP", for: .normal)
            case .denied, .restricted:
                self.statusIndicator.backgroundColor = UIColor(red: 0.90, green: 0.30, blue: 0.26, alpha: 1.0) // Red
                self.statusLabel.text = "Bị từ chối truy cập. Vui lòng bật trong Cài đặt."
                self.permissionButton.isEnabled = true
                self.permissionButton.alpha = 1.0
                self.permissionButton.setTitle("MỞ CÀI ĐẶT HỆ THỐNG", for: .normal)
            case .notDetermined:
                self.statusIndicator.backgroundColor = .systemOrange
                self.statusLabel.text = "Chưa cấp quyền truy cập thư viện ảnh."
                self.permissionButton.isEnabled = true
                self.permissionButton.alpha = 1.0
                self.permissionButton.setTitle("CẤP QUYỀN TRUY CẬP ẢNH", for: .normal)
            @unknown default:
                break
            }
        }
    }
    
    @objc private func permissionButtonTapped() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied || status == .restricted {
            // Mở cài đặt app
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                self?.updateUI(for: newStatus)
            }
        }
    }
    
    // MARK: - Micro-animations
    @objc private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.permissionButton.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.permissionButton.alpha = 0.9
        }
    }
    
    @objc private func buttonTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.permissionButton.transform = .identity
            self.permissionButton.alpha = 1.0
        }
    }
}
