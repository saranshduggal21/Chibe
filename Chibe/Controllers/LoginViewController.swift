import UIKit
import Firebase

class LoginViewController: UIViewController, Errors {
    
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = userEmailTextField.text, let password = userPasswordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    let errorDescription = "\(err.localizedDescription)"
                    self.errorAlert(title: "Error", error: errorDescription)
                }
                else {
                    self.performSegue(withIdentifier: "LoginToChibe", sender: self)
                }
            }
            
        }
    }
    
}
