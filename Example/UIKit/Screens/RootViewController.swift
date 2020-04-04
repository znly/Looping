import UIKit

import WebPImage

import GDPerformanceView_Swift

final class RootViewController: UIViewController {

    private let imageTypes = ["Animated", "Static"]
    private let animatedImages = WebPImageAsset.animated
    private let staticImages = WebPImageAsset.static

    private let contentModes: [UIView.ContentMode] = [
        .bottom, .bottomLeft, .bottomRight,
        .center, .left, .right,
        .scaleAspectFill, .scaleAspectFit, .scaleToFill,
        .top, .topLeft, .topRight
    ]

    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            performanceStackView,
            imageView,
            imageStackView,
            contentModeSelection,
            actionButtonStackView
        ]
        )..{
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 12
    }

    private lazy var performanceStackView = UIStackView(
        arrangedSubviews: [cpuLabel, fpsLabel, memoryLabel]
        )..{
            $0.distribution = .fillEqually
    }
    private let cpuLabel = UILabel()
    private let fpsLabel = UILabel()..{
        $0.textAlignment = .center
    }
    private let memoryLabel = UILabel()..{
        $0.textAlignment = .right
    }

    private lazy var imageView = WebPImageView()..{
        $0.delegate = self
        $0.activityDelegate = self
        $0.backgroundColor = UIColor(patternImage: UIImage(named: "TransparencyCheckerboard")!)
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.layer.borderWidth = 1
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

    private func load(asset: WebPImageAsset) {
        do {
            imageView.image = try asset.name.map {
                try WebPImage(named: $0)
            }

            imageView.play(completion: { finished in
                print("[WebPImageView] Play stopped with: \(finished)")
            })

        } catch {
            print(error.localizedDescription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6

        let performanceMonitor = PerformanceMonitor.shared()
        performanceMonitor.delegate = self
        performanceMonitor.start()

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        imageStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addConstraints(
            [
                imageStackView.heightAnchor.constraint(equalToConstant: 70),
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
                $0.image = imageView.image
            },
            animated: true
        )
    }

    @objc func imageOptionsTapped() {
        present(OptionsViewController(imageView: imageView), animated: true)
    }

    @objc func contentModeChanged() {
        imageView.contentMode = contentModes[contentModeSelection.selectedSegmentIndex]
    }

    @objc func playTapped() {
        imageView.play()
    }

    @objc func pauseTapped() {
        imageView.pause()
    }

    @objc func stopTapped() {
        imageView.stop()
    }
}

extension RootViewController: WebPImageViewDelegate {

    func imageView(_: WebPImageView, didStartPlayingImage image: WebPImage) {
        print("[WebPImageViewDelegate] did start animating \(image)")
    }

    func imageView(_: WebPImageView, didPausePlayingImage image: WebPImage) {
        print("[WebPImageViewDelegate] did pause animating \(image)")
    }

    func imageView(_: WebPImageView, didStopPlayingImage image: WebPImage) {
        print("[WebPImageViewDelegate] did stop animating \(image)")
    }

    func imageView(_: WebPImageView, didFinishPlayingImage image: WebPImage, loopMode: WebPImage.LoopMode) {
        print("[WebPImageViewDelegate] did complete animating \(image) after \(loopMode)")
    }
}

extension RootViewController: WebPImageViewActivityDelegate {

    func imageView(_ imageView: WebPImageView, didRenderFrameAtIndex index: Int) {
        print("[WebPImageViewActivityDelegate] did render image at index \(index)")
    }

    func imageView(_ imageView: WebPImageView, didDisplay image: CGImage?) {
        let imageDescription = image.map { CGSize(width: $0.width, height: $0.height) } ?? .zero
        print("[WebPImageViewActivityDelegate] did display image \(imageDescription)")
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

extension RootViewController: PerformanceMonitorDelegate {

    func performanceMonitor(didReport performanceReport: PerformanceReport) {
        cpuLabel.text = "CPU \(Int(performanceReport.cpuUsage))%"
        fpsLabel.text = "\(performanceReport.fps) FPS"

        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.zeroPadsFractionDigits = true

        memoryLabel.text = "MEM \(formatter.string(fromByteCount: Int64(performanceReport.memoryUsage.used)))"
    }
}
