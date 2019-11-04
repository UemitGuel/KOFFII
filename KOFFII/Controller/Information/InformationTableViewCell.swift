import UIKit

class InformationTableViewCell: UITableViewCell {
    @IBOutlet var infoImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayer()
    }

    func setupLayer() {
        infoImageView.layer.cornerRadius = 8
    }
}
