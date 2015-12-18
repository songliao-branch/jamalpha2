
import UIKit

class MusicCell: UITableViewCell {

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!

    @IBOutlet weak var loudspeakerImage: UIImageView!

    @IBOutlet weak var demoImage: UIImageView!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    //50 if loudspeaker is shown, otherwise 15
    override func awakeFromNib() {

        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
