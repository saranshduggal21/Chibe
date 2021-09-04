import UIKit
import CLTypingLabel //Importing CLTypingLabel Pod class.

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var chibeLabel: UILabel!
    @IBOutlet weak var sloganLabel: CLTypingLabel! //Changed the class of the text we want to animate, from UITypingLabel to CLTypingLabel.
    
    override func viewWillAppear(_ animated: Bool) { //viewWillAppear is just before the view loads up on the screen.
        super.viewWillAppear(animated)
        //Whenever we're overriding one of these lifecycle methods like "viewWillAppear" & "viewWillDisappear" we have to call "super" within our implementation.
        //Super just means that the parent (the UIViewController, which our class is inheriting from), gets an opportunity to run its own code inside its own "viewWillAppear" & "viewWillDisappear", and then afterwards, we can run our own code which has our custom functionality. 
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) { //As soon as the welcome screen disappears, the navigation bar unhides itself so that it can show up on all the other upcoming screens.
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sloganLabel.text = "Where you can Chat & Vibe!" //Telling CLTypingLabel, exactly what text we want it to animate.
    }
    
}







// MARK: - CHIBE Typing Animation (Timer & Loop Method)

//        chibeLabel.text = ""
//        let welcomeScreenLabel = "     ⚡️Chibe     "
//        var characterIndex = 0
//        for character in welcomeScreenLabel {
//            Timer.scheduledTimer(withTimeInterval: 0.1 * Double(characterIndex), repeats: false) { (titleTimer) in
//                self.chibeLabel.text?.append(character) //Adding in each letter to the for loop by APPENDING each character.
//            }
//            //Our computers run extremely fast so it doesn't take it any time at all to loop through the letters inside the welcomeScreenLabel in the for loop. Thus, we can't see that animation of typing. In order to solve this, we have to create a TIMER so that we add each letter after an incremental amount of time.
//
//            characterIndex += 1 //characterIndex is being used to multiply the timeInterval with so that we can delay each letter by 0.1 of a second (0.1 * 0 = 0, 0.1 * 1 = 0.1, 0.1 * 2 = 0.2, etc.).
//        }

