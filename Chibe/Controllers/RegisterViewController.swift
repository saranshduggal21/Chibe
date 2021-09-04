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
            //Optional binding is being used in order to turn "userEmailTextField.text" & "userPasswordTextField.text" (optional Strings) into a real string so that they can be used as inputs in line 30.
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    let errorDescription = "\(err.localizedDescription)"
                    //Converted the entire "err" variable into a string, stored in "errorDescription".
                    self.errorAlert(title: "Error", error: errorDescription)
                }
                else {
                    //"Else" = user has successfully been registered.
                    
                    self.performSegue(withIdentifier: "RegisterToChibe", sender: self) //This function will trigger the segue between the Register and Chat screens.
                    
                }
            }
            
        }
        
        
    }
    
}


