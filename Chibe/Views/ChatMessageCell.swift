import UIKit

class ChatMessageCell: UITableViewCell {

    @IBOutlet weak var messageBubbleView: UIView!
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var otherUserAvatarImage: UIImageView!
    
    override func awakeFromNib() { //Going to initalize whatever we design in our ChatMessageCell.xib file.
        super.awakeFromNib()
        
        messageBubbleView.layer.cornerRadius = messageBubbleView.frame.size.height / 4
        //The line above progamatically rounds the corner of each text bubble. The level of how rounded the chat message will is dependent on the height of the message bubble which is then divided by 4. Thus, the message's corner radius then adapts with the height of the message.
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
