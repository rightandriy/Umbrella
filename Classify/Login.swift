/* =======================
 
 - Umbrella -
 
 made by Bring Me©2016
 Andriy Pryvalov
 
 ==========================*/

import UIKit
import Parse


class Login: UIViewController,
UITextFieldDelegate,
UIAlertViewDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var loginOutlet: UIButton!
    @IBOutlet var signupOutlet: UIButton!
    @IBOutlet weak var fbOutlet: UIButton!
    
    @IBOutlet var bkgViews: [UIView]!

    
    
    

override func viewWillAppear(animated: Bool) {
    if PFUser.currentUser() != nil {
        navigationController?.popViewControllerAnimated(true)
    }
}
override func viewDidLoad() {
        super.viewDidLoad()
    
    self.title = "LOGIN"
    let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
    navigationItem.leftBarButtonItem = backButton
    
    
    // Round views corners
    loginOutlet.layer.cornerRadius = 5
    signupOutlet.layer.cornerRadius = 5
    fbOutlet.layer.cornerRadius = 5
    for view in bkgViews { view.layer.cornerRadius = 8 }

    
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 550)
}

    
// MARK: - LOGIN BUTTON
@IBAction func loginButt(sender: AnyObject) {
    passwordTxt.resignFirstResponder()
    showHUD()

    PFUser.logInWithUsernameInBackground(usernameTxt.text!, password:passwordTxt.text!) {
        (user, error) -> Void in
        
        if user != nil { // Login successfull
            self.hideHUD()
            self.navigationController?.popViewControllerAnimated(true)
            
        } else { // Login failed. Try again
            let alert = UIAlertView(title: APP_NAME,
            message: "Login Error",
            delegate: self,
            cancelButtonTitle: "Retry",
            otherButtonTitles: "Sign Up")
            alert.show()
            self.hideHUD()
    } }
    
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Sign Up" {
        signupButt(self)
    }
    
    if alertView.buttonTitleAtIndex(buttonIndex) == "Reset Password" {
        PFUser.requestPasswordResetForEmailInBackground("\(alertView.textFieldAtIndex(0)!.text!)")
        showNotifAlert()
    }
}

    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewControllerWithIdentifier("Signup") as! Signup
    navigationController?.pushViewController(signupVC, animated: true)
}
  
    
    
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt { passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt  { passwordTxt.resignFirstResponder() }
    
return true
}
    
    

// MARK: - TAP THE VIEW TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}
    
    
    
// MARK: - FORGOT PASSWORD BUTTON
@IBAction func forgotPasswButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
        message: "Type your email address you used to register.",
        delegate: self,
        cancelButtonTitle: "Cancel",
        otherButtonTitles: "Reset Password")
    alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
    alert.show()
}


// MARK: - NOTIFICATION ALERT FOR PASSWORD RESET
func showNotifAlert() {
    simpleAlert("You will receive an email shortly with a link to reset your password")
}
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
}
}
