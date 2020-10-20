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
            autoPlayStackView
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

    private lazy var autoPlayStackView = UIStackView(arrangedSubviews: [autoPlayLabel, autoPlaySwitch])
    private let autoPlayLabel = UILabel()..{
        $0.text = "AUTOPLAY"
    }
    private lazy var autoPlaySwitch = UISwitch()..{
        $0.isOn = loopView.autoPlay
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
        autoPlaySwitch.addTarget(self, action: #selector(autoPlayChanged), for: .valueChanged)
    }

    @objc func loopChanged() {
        loopView.loopMode = loops[loopSelection.selectedSegmentIndex].value
    }

    @objc func autoPlayChanged() {
        loopView.autoPlay = autoPlaySwitch.isOn
    }
}
