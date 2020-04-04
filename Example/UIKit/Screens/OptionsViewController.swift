import UIKit

import WebPImage

final class OptionsViewController: UIViewController {
    private let imageView: WebPImageView
    private let loops = Loop.allCases
    private let interpolations: [CGInterpolationQuality] = [
        .none, .low, .medium, .high
    ]

    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            loopStackView,
            displayScaleStackView,
            thumbnailStackView,
            interpolationStackView,
            playbackSpeedStackView,
            autoPlayStackView,
            useCacheStackView
        ]
        )..{
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 12
    }

    private lazy var loopStackView = UIStackView(arrangedSubviews: [loopLabel, loopSelection])
    private let loopLabel = UILabel()..{
        $0.text = "OVERRIDE LOOP"
    }
    private lazy var loopSelection = UISegmentedControl(items: loops.map { $0.description })..{
        $0.selectedSegmentIndex = 0
    }

    private lazy var thumbnailStackView = UIStackView(arrangedSubviews: [thumbnailLabel, thumbnailSwitch])
    private let thumbnailLabel = UILabel()..{
        $0.text = "GENERATE THUMBNAIL"
    }
    private lazy var thumbnailSwitch = UISwitch()..{
        $0.isOn = imageView.generateThumbnail
    }

    private lazy var interpolationStackView = UIStackView(arrangedSubviews: [interpolationLabel, interpolationSelection])
    private let interpolationLabel = UILabel()..{
        $0.text = "↳ INTERPOLATION"
    }
    private lazy var interpolationSelection = UISegmentedControl(items: interpolations.map { $0.description })..{
        $0.selectedSegmentIndex = interpolations.firstIndex(of: imageView.interpolationQuality) ?? 0
    }

    private lazy var displayScaleStackView = UIStackView(
        arrangedSubviews: [displayScaleLabel, displayScaleSelection]
        )..{
            $0.axis = .horizontal
            $0.distribution = .fillEqually
    }
    private let displayScaleLabel = UILabel()
    private lazy var displayScaleSelection = UISlider()..{
        $0.minimumValue = 0.25
        $0.maximumValue = 4
        $0.value = Float(imageView.displayScale)
    }

    private lazy var playbackSpeedStackView = UIStackView(
        arrangedSubviews: [playbackSpeedLabel, playbackSpeedSelection]
        )..{
            $0.axis = .horizontal
            $0.distribution = .fillEqually
    }
    private let playbackSpeedLabel = UILabel()

    private lazy var playbackSpeedSelection = UISlider()..{
        $0.minimumValue = .zero
        $0.maximumValue = 10
        $0.value = Float(imageView.playbackSpeed)
    }

    private lazy var autoPlayStackView = UIStackView(arrangedSubviews: [autoPlayLabel, autoPlaySwitch])
    private let autoPlayLabel = UILabel()..{
        $0.text = "AUTOPLAY"
    }
    private lazy var autoPlaySwitch = UISwitch()..{
        $0.isOn = imageView.autoPlay
    }

    private lazy var useCacheStackView = UIStackView(arrangedSubviews: [useCacheLabel, useCacheSwitch])
    private let useCacheLabel = UILabel()..{
        $0.text = "USE CACHE"
    }
    private lazy var useCacheSwitch = UISwitch()..{
        $0.isOn = imageView.useCache
    }

    init(imageView: WebPImageView) {
        self.imageView = imageView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addConstraints(
            [
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            ]
        )

        loopSelection.addTarget(self, action: #selector(loopChanged), for: .valueChanged)
        displayScaleSelection.addTarget(self, action: #selector(displayScaleChanged), for: .valueChanged)
        thumbnailSwitch.addTarget(self, action: #selector(thumbnailChanged), for: .valueChanged)
        interpolationSelection.addTarget(self, action: #selector(interpolationChanged), for: .valueChanged)
        playbackSpeedSelection.addTarget(self, action: #selector(playbackSpeedChanged), for: .valueChanged)
        autoPlaySwitch.addTarget(self, action: #selector(autoPlayChanged), for: .valueChanged)
        useCacheSwitch.addTarget(self, action: #selector(useCacheChanged), for: .valueChanged)

        loopChanged()
        displayScaleChanged()
        thumbnailChanged()
        playbackSpeedChanged()
    }


    @objc func loopChanged() {
        imageView.loopMode = loops[loopSelection.selectedSegmentIndex].value
    }

    @objc func displayScaleChanged() {
        let value = displayScaleSelection.value.rounded(nearest: 0.25)
        displayScaleLabel.text = "DISPLAY SCALE \(value)"
        imageView.displayScale = CGFloat(value)
    }

    @objc func thumbnailChanged() {
        imageView.generateThumbnail = thumbnailSwitch.isOn
    }

    @objc func interpolationChanged() {
        imageView.interpolationQuality = interpolations[interpolationSelection.selectedSegmentIndex]
    }

    @objc func playbackSpeedChanged() {
        let value = playbackSpeedSelection.value.rounded(nearest: 0.1)
        playbackSpeedLabel.text = "PLAYBACK SPEED \(value)"
        imageView.playbackSpeed = Double(value)
    }

    @objc func autoPlayChanged() {
        imageView.autoPlay = autoPlaySwitch.isOn
    }

    @objc func useCacheChanged() {
        imageView.useCache = useCacheSwitch.isOn
    }
}
