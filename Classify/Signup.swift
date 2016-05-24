/* =======================
 
 - Umbrella -
 
 made by Bring Me©2016
 Andriy Pryvalov
 
 ==========================*/


import UIKit
import Parse


class Signup: UIViewController,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var signupOutlet: UIButton!
    @IBOutlet weak var touOutlet: UIButton!
    
    @IBOutlet var bkgViews: [UIView]!
    
    
   

override func viewDidLoad() {
        super.viewDidLoad()
    
    self.title = "SIGN UP"
    
    // Round views corners
    signupOutlet.layer.cornerRadius = 5
    touOutlet.layer.cornerRadius = 5
    for view in bkgViews { view.layer.cornerRadius = 8 }
    
    
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 300)
}
    

// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
}
 
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {
    showHUD()
    
    let userForSignUp = PFUser()
    userForSignUp.username = usernameTxt.text
    userForSignUp.password = passwordTxt.text
    userForSignUp.email = emailTxt.text
    
    userForSignUp.signUpInBackgroundWithBlock { (succeeded, error) -> Void in
        if error == nil { // Successful Signup
            self.navigationController?.popToRootViewControllerAnimated(true)
            self.hideHUD()
            
        } else { // No signup, something went wrong
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    } }
  
}
   
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt {   passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()  }
    if textField == emailTxt {   emailTxt.resignFirstResponder()   }
        
return true
}


    
// MARK: - TERMS OF USE BUTTON
@IBAction func touButt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    presentViewController(touVC, animated: true, completion: nil)
}
    
    
    

    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
