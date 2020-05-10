import UIKit

import Looping

final class OptionsViewController: UIViewController {
    private let loopView: LoopView
    private let loops = LoopMode.allCases
    private let interpolations: [CGInterpolationQuality] = [
        .none, .low, .medium, .high
    ]

    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            loopStackView,
            displayScaleStackView,
            thumbnailStackView,
            interpolationStackView,
            playBackSpeedRateStackView,
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
        guard let loopMode = loopView.loopMode else {
            $0.selectedSegmentIndex = 0
            return
        }

        switch loopMode {
        case .once:
            $0.selectedSegmentIndex = 2
        case let .repeat(amount):
            switch amount {
            case 1:
                $0.selectedSegmentIndex = 2
            case 2:
                $0.selectedSegmentIndex = 3
            case 5:
                $0.selectedSegmentIndex = 4
            case 10:
                $0.selectedSegmentIndex = 5
            default:
                $0.selectedSegmentIndex = 1
            }
        case .infinite:
            $0.selectedSegmentIndex = 1
        }

    }

    private lazy var thumbnailStackView = UIStackView(arrangedSubviews: [thumbnailLabel, thumbnailSwitch])
    private let thumbnailLabel = UILabel()..{
        $0.text = "GENERATE THUMBNAIL"
    }
    private lazy var thumbnailSwitch = UISwitch()..{
        $0.isOn = loopView.generateThumbnail
    }

    private lazy var interpolationStackView = UIStackView(arrangedSubviews: [interpolationLabel, interpolationSelection])
    private let interpolationLabel = UILabel()..{
        $0.text = "↳ INTERPOLATION"
    }
    private lazy var interpolationSelection = UISegmentedControl(items: interpolations.map { $0.description })..{
        $0.selectedSegmentIndex = interpolations.firstIndex(of: loopView.interpolationQuality) ?? 0
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
        $0.value = Float(loopView.displayScale)
    }

    private lazy var playBackSpeedRateStackView = UIStackView(
        arrangedSubviews: [playBackSpeedRateLabel, playBackSpeedRateSelection]
        )..{
            $0.axis = .horizontal
            $0.distribution = .fillEqually
    }
    private let playBackSpeedRateLabel = UILabel()

    private lazy var playBackSpeedRateSelection = UISlider()..{
        $0.minimumValue = .zero
        $0.maximumValue = 10
        $0.value = Float(loopView.playBackSpeedRate)
    }

    private lazy var autoPlayStackView = UIStackView(arrangedSubviews: [autoPlayLabel, autoPlaySwitch])
    private let autoPlayLabel = UILabel()..{
        $0.text = "AUTOPLAY"
    }
    private lazy var autoPlaySwitch = UISwitch()..{
        $0.isOn = loopView.autoPlay
    }

    private lazy var useCacheStackView = UIStackView(arrangedSubviews: [useCacheLabel, useCacheSwitch])
    private let useCacheLabel = UILabel()..{
        $0.text = "USE CACHE"
    }
    private lazy var useCacheSwitch = UISwitch()..{
        $0.isOn = loopView.useCache
    }

    init(loopView: LoopView) {
        self.loopView = loopView
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
        playBackSpeedRateSelection.addTarget(self, action: #selector(playBackSpeedRateChanged), for: .valueChanged)
        autoPlaySwitch.addTarget(self, action: #selector(autoPlayChanged), for: .valueChanged)
        useCacheSwitch.addTarget(self, action: #selector(useCacheChanged), for: .valueChanged)

        displayScaleChanged()
        thumbnailChanged()
        playBackSpeedRateChanged()
    }


    @objc func loopChanged() {
        loopView.loopMode = loops[loopSelection.selectedSegmentIndex].value
    }

    @objc func displayScaleChanged() {
        let value = displayScaleSelection.value.rounded(nearest: 0.25)
        displayScaleLabel.text = "DISPLAY SCALE \(value)"
        loopView.displayScale = CGFloat(value)
    }

    @objc func thumbnailChanged() {
        loopView.generateThumbnail = thumbnailSwitch.isOn
    }

    @objc func interpolationChanged() {
        loopView.interpolationQuality = interpolations[interpolationSelection.selectedSegmentIndex]
    }

    @objc func playBackSpeedRateChanged() {
        let value = playBackSpeedRateSelection.value.rounded(nearest: 0.1)
        playBackSpeedRateLabel.text = "PLAYBACK SPEED \(value)"
        loopView.playBackSpeedRate = Double(value)
    }

    @objc func autoPlayChanged() {
        loopView.autoPlay = autoPlaySwitch.isOn
    }

    @objc func useCacheChanged() {
        loopView.useCache = useCacheSwitch.isOn
    }
}
