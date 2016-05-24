/* =======================
 
 - Umbrella -
 
 made by Bring Me©2016
 Andriy Pryvalov
 
 ==========================*/


import UIKit
import Parse

class Account: UIViewController,
UITextFieldDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var fullnameTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var phoneTxt: UITextField!
    @IBOutlet var websiteTxt: UITextField!
    @IBOutlet var saveProfileOutlet: UIButton!
    @IBOutlet var myAdsOutlet: UIButton!
    
    
    /* Variables */
    var userArray = [PFObject]()
    
    
    
    
    
// MARK: - CHECK IF USER IS LOGGED IN
override func viewWillAppear(animated: Bool) {
    
    if PFUser.currentUser() == nil {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        navigationController?.pushViewController(loginVC, animated: false)
    } else {
        showUserDetails()
    }
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Round views corners
    avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
    saveProfileOutlet.layer.cornerRadius = 8
    myAdsOutlet.layer.cornerRadius = 8

    
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 550)
}

    

// MARK: - SHOW USER DETIALS
func showUserDetails() {
    let currUser = PFUser.currentUser()!
    
    usernameLabel.text = "\(currUser[USER_USERNAME]!)"
    emailTxt.text = "\(currUser[USER_EMAIL]!)"
    
    if currUser[USER_FULLNAME] != nil {
        fullnameTxt.text = "\(currUser[USER_FULLNAME]!)"
    } else { fullnameTxt.text = "" }
    
    if currUser[USER_PHONE] != nil {
        phoneTxt.text = "\(currUser[USER_PHONE]!)"
    } else { phoneTxt.text = "" }
    
    if currUser[USER_WEBSITE] != nil {
        websiteTxt.text = "\(currUser[USER_WEBSITE]!)"
    } else { websiteTxt.text = "" }
    
     // Get Avatar image
    let imageFile = currUser[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackgroundWithBlock ({ (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.avatarImage.image = UIImage(data:imageData)
    }}})
}
    
    
    
// MARK: - TEXTFIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == fullnameTxt {  emailTxt.becomeFirstResponder()  }
    if textField == emailTxt    {  phoneTxt.becomeFirstResponder()  }
    if textField == phoneTxt    {  websiteTxt.becomeFirstResponder()  }
    if textField == websiteTxt  {  websiteTxt.resignFirstResponder()  }

return true
}

    
// MARK: - CHANGE IMAGE BUTTON
@IBAction func changeImageButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Add a Photo",
    delegate: self,
    cancelButtonTitle: "Cancel",
    otherButtonTitles:
            "Take a picture",
            "Choose from Library"
    )
    alert.show()
    
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "Take a picture" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
            
        } else if alertView.buttonTitleAtIndex(buttonIndex) == "Choose from Library" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
}
// ImagePicker Delegate
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    avatarImage.image = image
    dismissViewControllerAnimated(true, completion: nil)
}
    
    

// MARK: - SAVE PROFILE BUTTON
@IBAction func saveProfileButt(sender: AnyObject) {
    showHUD()
    let currentUser = PFUser.currentUser()!
    
    currentUser[USER_FULLNAME] = fullnameTxt.text
    currentUser[USER_EMAIL] = emailTxt.text
    currentUser[USER_PHONE] = phoneTxt.text
    currentUser[USER_WEBSITE] = websiteTxt.text

    // Save Image (if exists)
    if avatarImage.image != nil {
        let imageData = UIImageJPEGRepresentation(avatarImage.image!,0.2)
        let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
        currentUser[USER_AVATAR] = imageFile
    }
    
    // Saving block
    currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            self.simpleAlert("Your Profile has been updated!")
        self.hideHUD()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}

    
    
// MARK: - POST A NEW AD BUTTON
@IBAction func postAdButt(sender: AnyObject) {
    let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
    presentViewController(postVC, animated: true, completion: nil)
}
    
    
    
// MARK: - MY ADS BUTTON
@IBAction func myAdsButt(sender: AnyObject) {
    let myAdsVC = self.storyboard?.instantiateViewControllerWithIdentifier("MyAds") as! MyAds
    self.navigationController?.pushViewController(myAdsVC, animated: true)
}
    
    
    
// MARK: - LOGOUT BUTTON
@IBAction func logoutButt(sender: AnyObject) {
    PFUser.logOut()
    
    let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
    navigationController?.pushViewController(loginVC, animated: true)
}
  

    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
    fullnameTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    phoneTxt.resignFirstResponder()
    websiteTxt.resignFirstResponder()
}
    

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
