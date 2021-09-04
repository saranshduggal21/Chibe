import UIKit
import Firebase

public protocol Errors: UIViewController {
    func errorAlert(title: String, error: String)
}

extension Errors {
    func errorAlert (title: String, error: String) { //This function is being used to create an error pop-up when an error is found when creating a user account.
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            //The following is what occurs when the "OK" button is clicked. In this case, the alert will disappear/hide after the user clicks "OK".
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

class RegisterViewController: UIViewController, Errors {
    
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = userEmailTextField.text, let password = userPasswordTextField.text {
            //In line 11, optional binding is being used in order to turn "userEmailTextField.text" & "userPasswordTextField.text" (optional Strings) into a real string so that they can be used as inputs in line 15.
            //Furthermore, the "," in between the 2 variables in line 11 is a form of CHAINING, where it's saying that if both "userEmailTextField.text" & "userPasswordTextField.text" aren't nill and can be turned into real strings stored inside "email" & "password" and don't fail then, run line 15 and actually create the user.
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let err = error { //Once again, optionally binding "error" (optional string) into a real string.
                    let errorDescription = "\(err.localizedDescription)" //Converted the entire "err" variable into a string, stored in "errorDescription".
                    //"localizedDescription" provides a description of the error that is localized to the language that user has selected on their iOS device. This decription doesn't contain any giberish about error codes and all, and will give the user the exact error that they're facing in understandable language.
                    self.errorAlert(title: "Error", error: errorDescription)
                }
                else { //If there are no errors or if "error" = nil, then the entire "if" block is going to get skipped and the "else" block will be initiated.
                    //If the "else" block is initiated then that means that the user has successfully been registered and now has to be navigated to the ChatViewController.
                    
                    self.performSegue(withIdentifier: "RegisterToChibe", sender: self) //This function will trigger the segue between the Register and Chat screens.
                    //Once again, since we're in a closure (as denoted by the "in" above and the {}), the self keyword has to be used infront of any methods that we're calling on the current class.
                    
                }
            }
            
        }
        
        
    }
    
}


