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
    private let frameIndicator = UIImageView(image: UIImage(systemName: "arrowtriangle.up.fill"))..{
        $0.tintColor = UIColor.systemGreen
    }
    private var timelineViews = [UIView]() {
        didSet {
            frameIndicator.removeFromSuperview()
            timelineView.arrangedSubviews.forEach {
                timelineView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            timelineViews.forEach {
                timelineView.addArrangedSubview($0)
            }
            timelineView.addSubview(frameIndicator)
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
            playBackSpeedRateStackView,
            actionButtonStackView
        ]
        )..{
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 12
    }

    private lazy var loopView = LoopView()..{
        $0.completionBehavior = .pause
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
        $0.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanTimeline)))
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

    private lazy var playBackSpeedRateStackView = UIStackView(
        arrangedSubviews: [playBackSpeedRateLabel, playBackSpeedRateSelection]
    )..{
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    private let playBackSpeedRateLabel = UILabel()

    private lazy var playBackSpeedRateSelection = UISlider()..{
        $0.minimumValue = -10
        $0.maximumValue = 10
        $0.value = Float(loopView.playBackSpeedRate)
    }

    private lazy var actionButtonStackView = UIStackView(
        arrangedSubviews: [clearButton, preheatButton, playButton, pauseButton, stopButton]
        )..{
            $0.distribution = .fillEqually
    }
    private lazy var clearButton = UIButton()..{
        $0.setImage(UIImage(systemName: "clear", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .systemRed
    }
    private lazy var preheatButton = UIButton()..{
        $0.setImage(UIImage(systemName: "flame", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .systemOrange
    }
    private lazy var playButton = UIButton()..{
        $0.setImage(UIImage(systemName: "play", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .systemGreen
    }
    private lazy var pauseButton = UIButton()..{
        $0.setImage(UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .systemTeal
    }
    private lazy var stopButton = UIButton()..{
        $0.setImage(UIImage(systemName: "stop", withConfiguration: UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        $0.tintColor = .white
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

            frameIndicator.isHidden = true
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
        playBackSpeedRateSelection.addTarget(self, action: #selector(playBackSpeedRateChanged), for: .valueChanged)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        preheatButton.addTarget(self, action: #selector(preheatTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)

        contentModeChanged()
        playBackSpeedRateChanged()
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

    @objc func playBackSpeedRateChanged() {
        let value = playBackSpeedRateSelection.value.rounded(nearest: 0.1)
        playBackSpeedRateLabel.text = "PLAYBACK SPEED \(value)"
        loopView.playBackSpeedRate = Double(value)
    }

    @objc func clearTapped() {
        loopView.clearCache()
    }

    @objc func preheatTapped() {
        loopView.preheatCache()
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

    @objc func handlePanTimeline(_ sender: UIPanGestureRecognizer) {
        let translation = sender.location(in: stackView)
        let seekProgress = Double(round(100 * translation.x / stackView.frame.width) / 100)
        let adjustedProgress = loopView.playBackSpeedRate > 0 ? seekProgress : 1 - seekProgress
        loopView.seek(progress: adjustedProgress, shouldResumePlaying: false)
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

        DispatchQueue.main.async {
            if self.timelineViews.indices.contains(index) {
                self.timelineViews[index].backgroundColor = didUseCache ? UIColor.systemGreen.withAlphaComponent(0.3) : UIColor.systemOrange.withAlphaComponent(0.3)
            }
        }
    }

    func loopView(_ loopView: LoopView, didDisplayImage image: UIImage?, forFrameAtIndex index: Int?) {
        os_log("[LoopViewActivityDelegate] did display image at index %{PUBLIC}d %{PUBLIC}@", log: OSLog.viewCycle, type: .debug, index ?? -1, image.debugDescription)

        if let index = index {
            DispatchQueue.main.async {
                if self.timelineViews.indices.contains(index) {
                    let cellFrame = self.timelineViews[index].frame

                    self.frameIndicator.isHidden = false
                    self.frameIndicator.frame.origin = CGPoint(
                        x: cellFrame.midX - self.frameIndicator.frame.width * 0.5,
                        y: cellFrame.maxY
                    )
                }
            }
        }
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
