import UIKit

enum AlertStyle {
    case error
    case success
    
    var color: UIColor {
        switch self {
        case .error:
            return .systemRed
        case .success:
            return .systemGreen
        }
    }
    
    var title: String {
        switch self {
        case .error:
            return "Error"
        case .success:
            return "Success"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .error:
            return UIImage(systemName: "xmark.circle.fill")
        case .success:
            return UIImage(systemName: "checkmark.circle.fill")
        }
    }
}

class AlertView: UIView {
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private var dismissCompletion: (() -> Void)?
    private var autoHideTimer: Timer?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(dimmedView)
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(okButton)
        
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 270),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            okButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            okButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            okButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            okButton.heightAnchor.constraint(equalToConstant: 44),
            okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    func show(style: AlertStyle, message: String, in viewController: UIViewController, autoDismiss: Bool = false, completion: (() -> Void)? = nil) {
        self.titleLabel.text = style.title
        self.messageLabel.text = message
        self.dismissCompletion = completion
        
        // Set style-specific properties
        self.iconImageView.image = style.icon
        self.iconImageView.tintColor = style.color
        self.okButton.backgroundColor = style.color
        
        frame = viewController.view.bounds
        translatesAutoresizingMaskIntoConstraints = false
        
        viewController.view.addSubview(self)
        
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: viewController.view.topAnchor),
            leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        // Animation
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0
        dimmedView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
            self.dimmedView.alpha = 1
        }
        
        if autoDismiss {
            autoHideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                self?.dismiss()
            }
        }
    }
    
    // MARK: - Actions
    @objc private func okButtonTapped() {
        dismiss()
    }
    
    @objc private func dimmedViewTapped() {
        dismiss()
    }
    
    private func dismiss() {
        autoHideTimer?.invalidate()
        autoHideTimer = nil
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView.alpha = 0
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
            self.dismissCompletion?()
        }
    }
}
