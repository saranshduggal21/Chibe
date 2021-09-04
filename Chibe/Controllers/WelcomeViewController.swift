import UIKit
import CLTypingLabel //Importing CLTypingLabel Pod class.

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var chibeLabel: UILabel!
    @IBOutlet weak var sloganLabel: CLTypingLabel! //Changed the class of the text we want to animate, from UITypingLabel to CLTypingLabel.
    
    override func viewWillAppear(_ animated: Bool) { //viewWillAppear is just before the view loads up on the screen.
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sloganLabel.text = "Where you can Chat & Vibe!" //Telling CLTypingLabel, exactly what text we want it to animate.
    }
    
}
