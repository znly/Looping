import UIKit

import Looping

final class DetailsTableViewController: UITableViewController {
    private typealias Section = (title: String, cells: [Cell])
    private typealias Cell = (title: String, subtitle: String?)
    private lazy var sections: [Section] = [Section]()

    var image: LoopImage? {
        didSet {
            updateSections()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let data = sections[indexPath.section].cells[indexPath.row]

        cell.textLabel?.text = data.title
        cell.detailTextLabel?.text = data.subtitle

        return cell
    }
}

private extension DetailsTableViewController {

    func updateSections() {
        if let image = image {
            let fps = String((Float(image.frameCount) / Float(image.duration)).rounded(nearest: 0.01))

            let imageInformation = Section(
                title: "Image information",
                cells: [
                    Cell(title: image.isAnimation ? "Animated image" : "Static image", subtitle: nil),
                    Cell(title: "\(fps) FPS", subtitle: "\(image.frameCount) frames over \(Int(image.duration * 1000)) ms"),
                    Cell(title: "\(image.scale) scale", subtitle: nil),
                    Cell(title: "\(image.size.width)x\(image.size.height) size", subtitle: nil),
                    Cell(title: "\(image.canvasSize.width)x\(image.canvasSize.height) canvas size", subtitle: nil),
                    Cell(title: "\(image.loopMode)", subtitle: nil),
                    Cell(title: image.hasAlpha ? "With alpha" : "Without alpha", subtitle: nil)
                ]
            )

            let framesDuration = Section(
                title: "Frame durations",
                cells: image.framesDuration.enumerated().map {
                    Cell(title: "Frame \($0.offset)", subtitle: "\(Int($0.element * 1000)) ms")
                }
            )

            sections = [imageInformation, framesDuration]
        } else {
            sections = [Section(title: "No image selected", cells: [])]
        }

        tableView.reloadData()
    }
}
