import UIKit
import os.log

import Looping

private extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let viewCycle = OSLog(subsystem: subsystem, category: "viewcycle")
}

final class RootViewController: UIViewController {

    private let imageTypes = ["Animated", "Static"]
    private let animatedImages = ImageAsset.animations
    private let staticImages = ImageAsset.stills
    private var cachedFrames = Set<Int>()
    private var timelineViews = [UIView]() {
        didSet {
            timelineView.arrangedSubviews.forEach {
                timelineView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            timelineViews.forEach {
                timelineView.addArrangedSubview($0)
            }
        }
    }

    private let contentModes: [UIView.ContentMode] = [
        .bottom, .bottomLeft, .bottomRight,
        .center, .left, .right,
        .scaleAspectFill, .scaleAspectFit, .scaleToFill,
        .top, .topLeft, .topRight
    ]

    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            loopView,
            timelineView,
            imageStackView,
            contentModeSelection,
            actionButtonStackView
        ]
        )..{
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 12
    }

    private lazy var loopView = LoopView()..{
        $0.delegate = self
        $0.activityDelegate = self
        $0.backgroundColor = UIColor(patternImage: UIImage(named: "TransparencyCheckerboard")!)
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.layer.borderWidth = 1
    }

    private lazy var timelineView = UIStackView()..{
        $0.axis = .horizontal
        $0.spacing = -1
        $0.distribution = .fillEqually
    }

    private lazy var imageStackView = UIStackView(arrangedSubviews: [imageSelection, imageActionsStackView])..{
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.spacing = 20
    }

    private lazy var imageSelection = UIPickerView()..{
        $0.dataSource = self
        $0.delegate = self
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private lazy var imageActionsStackView = UIStackView(arrangedSubviews: [imageOptionsButton, imageDetailsButton])..{
        $0.axis = .vertical
    }

    private let imageOptionsButton = UIButton()..{
        let icon = UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        $0.setImage(icon, for: .normal)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    private let imageDetailsButton = UIButton()..{
        let icon = UIImage(systemName: "info.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        $0.setImage(icon, for: .normal)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private lazy var contentModeSelection = UISegmentedControl(items: contentModes.map { $0.description })..{
        $0.selectedSegmentIndex = contentModes.firstIndex(of: .center) ?? 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private lazy var actionButtonStackView = UIStackView(
        arrangedSubviews: [playButton, pauseButton, stopButton]
        )..{
            $0.distribution = .fillEqually
    }
    private lazy var playButton = UIButton()..{
        $0.setTitle("PLAY", for: .normal)
        $0.backgroundColor = .systemGreen
    }
    private lazy var pauseButton = UIButton()..{
        $0.setTitle("PAUSE", for: .normal)
        $0.backgroundColor = .systemTeal
    }
    private lazy var stopButton = UIButton()..{
        $0.setTitle("STOP", for: .normal)
        $0.backgroundColor = .systemPink
    }

    private func load(asset: ImageAsset) {
        do {
            loopView.loopImage = try asset.filename.map {
                try LoopImage(named: $0)
            }

            loopView.play(completion: { finished in
                os_log("[LoopView] Play stopped %{PUBLIC}@", log: OSLog.viewCycle, type: .debug, finished ? "by finishing" : "interrupted")
            })

            cachedFrames = []
            timelineViews = (0..<(loopView.loopImage?.frameCount ?? 1))
                .map { _ in
                    UIView()..{
                        $0.layer.borderWidth = 1
                        $0.layer.borderColor = UIColor.lightGray.cgColor
                    }
            }
        } catch {
            os_log("%{PUBLIC}@", log: OSLog.viewCycle, type: .error, error.localizedDescription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        imageStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addConstraints(
            [
                imageStackView.heightAnchor.constraint(equalToConstant: 70),
                timelineView.heightAnchor.constraint(equalToConstant: 20),
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            ]
        )

        imageOptionsButton.addTarget(self, action: #selector(imageOptionsTapped), for: .touchUpInside)
        imageDetailsButton.addTarget(self, action: #selector(imageDetailsTapped), for: .touchUpInside)
        contentModeSelection.addTarget(self, action: #selector(contentModeChanged), for: .valueChanged)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)

        contentModeChanged()
    }

    @objc func imageDetailsTapped() {
        present(
            DetailsTableViewController(style: .grouped)..{
                $0.image = loopView.loopImage
            },
            animated: true
        )
    }

    @objc func imageOptionsTapped() {
        present(OptionsViewController(loopView: loopView), animated: true)
    }

    @objc func contentModeChanged() {
        loopView.contentMode = contentModes[contentModeSelection.selectedSegmentIndex]
    }

    @objc func playTapped() {
        loopView.play()
    }

    @objc func pauseTapped() {
        loopView.pause()
    }

    @objc func stopTapped() {
        loopView.stop()
    }
}

extension RootViewController: LoopViewDelegate {

    func loopView(_: LoopView, didStartPlayingImage image: LoopImage) {
        os_log("[LoopViewDelegate] did start animating %{PUBLIC}@", log: OSLog.viewCycle, type: .debug, image.debugDescription)
    }

    func loopView(_: LoopView, didPausePlayingImage image: LoopImage) {
        os_log("[LoopViewDelegate] did pause animating %{PUBLIC}@", log: OSLog.viewCycle, type: .debug, image.debugDescription)
    }

    func loopView(_: LoopView, didStopPlayingImage image: LoopImage) {
        os_log("[LoopViewDelegate] did stop animating %{PUBLIC}@", log: OSLog.viewCycle, type: .debug, image.debugDescription)
    }

    func loopView(_: LoopView, didFinishPlayingImage image: LoopImage, loopMode: LoopImage.LoopMode) {
        os_log("[LoopViewDelegate] did complete animating %{PUBLIC}@(1) after %{PUBLIC}@", log: OSLog.viewCycle, type: .debug, image.debugDescription, loopMode.description)
    }
}

extension RootViewController: LoopViewActivityDelegate {

    func loopView(_ loopView: LoopView, didRenderFrameAtIndex index: Int, fromCache didUseCache: Bool) {
        os_log("[LoopViewActivityDelegate] did render image at index %{PUBLIC}d %{PUBLIC}@", log: OSLog.viewCycle, type: .debug, index, didUseCache ? "from cache" : "from context")

        let frameCount = loopView.loopImage?.frameCount ?? 1
        let frameIndex = index % frameCount

        if didUseCache || loopView.useCache {
            cachedFrames.insert(frameIndex)
        } else {
            cachedFrames.remove(frameIndex)
        }

        timelineViews.enumerated()
            .forEach { (viewIndex, view) in
                if viewIndex == frameIndex {
                    view.backgroundColor = didUseCache ? UIColor.systemGreen : UIColor.systemBlue
                } else if cachedFrames.contains(viewIndex) {
                    view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
                } else {
                    view.backgroundColor = .clear
                }
        }
    }

    func loopView(_ loopView: LoopView, didDisplay image: UIImage?) {
        os_log("[LoopViewActivityDelegate] did display image %{PUBLIC}@", log: OSLog.viewCycle, type: .debug, image.debugDescription)
    }
}

extension RootViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    private func isAnimatedSelected(in pickerView: UIPickerView) -> Bool {
        return pickerView.selectedRow(inComponent: 0) == 0
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return imageTypes.count
        }
        return isAnimatedSelected(in: pickerView)
            ? animatedImages.count
            : staticImages.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return imageTypes[row]
        }
        return isAnimatedSelected(in: pickerView)
            ? animatedImages[row].description
            : staticImages[row].description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: false)
            load(asset: .none)
            return
        }
        let asset = isAnimatedSelected(in: pickerView)
            ? animatedImages[row]
            : staticImages[row]
        load(asset: asset)
    }
}
