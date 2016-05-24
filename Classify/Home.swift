/* =======================
 
 - Umbrella -
 
 made by Bring Me©2016
 Andriy Pryvalov
 
 ==========================*/


import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Home: UIViewController,
UITextFieldDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
GADInterstitialDelegate
{

    /* Views */
    @IBOutlet var searchOutlet: UIButton!
    @IBOutlet var termsOfUseOutlet: UIButton!
    
    @IBOutlet var fieldsView: UIView!
    @IBOutlet var keywordsTxt: UITextField!
    @IBOutlet var whereTxt: UITextField!
    @IBOutlet var categoryTxt: UITextField!
    
    @IBOutlet var categoryContainer: UIView!
    @IBOutlet var categoryPickerView: UIPickerView!
    
    @IBOutlet var categoriesScrollView: UIScrollView!
    
    var adMobInterstitial: GADInterstitial!

    
    /* Variables */
    var classifArray = [PFObject]()
    var catButton = UIButton()
    
    
    
    
    

override func viewWillAppear(animated: Bool) {
    searchedAdsArray.removeAll()
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Init AdMob interstitial
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(36 * Double(NSEC_PER_SEC)))
    adMobInterstitial = GADInterstitial(adUnitID: ADMOB_UNIT_ID)
    adMobInterstitial.loadRequest(GADRequest())
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.showInterstitial()
    }
    
    
    // Round views corners
    searchOutlet.layer.cornerRadius = 8
    searchOutlet.layer.shadowColor = UIColor.blackColor().CGColor
    searchOutlet.layer.shadowOffset = CGSizeMake(0, 1.5)
    searchOutlet.layer.shadowOpacity = 0.8

    termsOfUseOutlet.layer.cornerRadius = 8
    
    
    // Put fieldsView in the center of the screen
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
        fieldsView.center = CGPointMake(view.frame.size.width/2, 300 )
    }
    
    // Hide the Categ. PickerView
    categoryContainer.frame.origin.y = view.frame.size.height
    view.bringSubviewToFront(categoryContainer)
    
    setupCategoriesScrollView()
    
}

    
// MARK: - SETUP CATEGORIES SCROLL VIEW
func setupCategoriesScrollView() {
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 0
        let buttonWidth:CGFloat = 90
        let buttonHeight: CGFloat = 90
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        
        // Loop for creating buttons ========
        for i in 0..<categoriesArray.count {
            itemCount = i
            
            // Create a Button
            catButton = UIButton(type: UIButtonType.Custom)
            catButton.frame = CGRectMake(xCoord, yCoord, buttonWidth, buttonHeight)
            catButton.tag = itemCount
            catButton.showsTouchWhenHighlighted = true
            catButton.setTitle("\(categoriesArray[itemCount])", forState: UIControlState.Normal)
            catButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 12)
            catButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            catButton.setBackgroundImage(UIImage(named: "\(categoriesArray[itemCount])"), forState: UIControlState.Normal)
            catButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom
            catButton.layer.cornerRadius = 5
            catButton.clipsToBounds = true
            catButton.addTarget(self, action: #selector(catButtTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            // Add Buttons & Labels based on xCood
            xCoord +=  buttonWidth + gapBetweenButtons
            categoriesScrollView.addSubview(catButton)
        } // END LOOP ================================
    
        // Place Buttons into the ScrollView =====
        categoriesScrollView.contentSize = CGSizeMake( (buttonWidth+5) * CGFloat(itemCount), yCoord)
}

    
    
    
// MARK: - ADMOB INTESRSTITIAL
func showInterstitial() {
    // Show AdMob interstitial
    if adMobInterstitial.isReady {
        adMobInterstitial.presentFromRootViewController(self)
        print("present Interstitial")
    }
}
    
    
    
    
// MARK: - CATEGORY BUTTON TAPPED
func catButtTapped(sender: UIButton) {
    let button = sender as UIButton
    let categoryStr = "\(button.titleForState(UIControlState.Normal)!)"
    
    searchedAdsArray.removeAll()
    showHUD()
    
    let query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_CATEGORY, equalTo: categoryStr)
    query.orderByAscending(CLASSIF_UPDATED_AT)
    query.limit = 30
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            searchedAdsArray = objects!
            
            // Go to Browse Ads VC
            let baVC = self.storyboard?.instantiateViewControllerWithIdentifier("BrowseAds") as! BrowseAds
            self.navigationController?.pushViewController(baVC, animated: true)
            self.hideHUD()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
    
// MARK: - SEARCH BUTTON
@IBAction func searchButt(sender: AnyObject) {
    searchedAdsArray.removeAll()

    let keywordsArray = keywordsTxt.text!.componentsSeparatedByString(" ") as NSArray
    showHUD()
    
    let query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_DESCRIPTION_LOWERCASE, containsString: "\(keywordsArray[0])")
    query.whereKey(CLASSIF_CATEGORY, equalTo: categoryTxt.text!)
    query.whereKey(CLASSIF_ADDRESS_STRING, containsString: whereTxt.text!.lowercaseString)
    query.orderByAscending(CLASSIF_UPDATED_AT)
    query.limit = 30
    
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            searchedAdsArray = objects!
            
            if searchedAdsArray.count > 0 {
            // Go to Browse Ads VC
            let baVC = self.storyboard?.instantiateViewControllerWithIdentifier("BrowseAds") as! BrowseAds
            self.navigationController?.pushViewController(baVC, animated: true)
            self.hideHUD()
            
            } else {
                self.simpleAlert("Nothing found with your search keywords, try different keywords, location or category")
                self.hideHUD()
            }
            
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
    

}

    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == categoryTxt {
        showCatPickerView()
        keywordsTxt.resignFirstResponder()
        whereTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
        
return true
}
    
func textFieldDidBeginEditing(textField: UITextField) {
    if textField == categoryTxt {
        showCatPickerView()
        keywordsTxt.resignFirstResponder()
        whereTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
}
    
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == keywordsTxt {  whereTxt.becomeFirstResponder(); hideCatPickerView()  }
    if textField == whereTxt {  categoryTxt.becomeFirstResponder()  }

return true
}
    
    
    
    
// MARK: - PICKERVIEW DELEGATES
func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1;
}

func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categoriesArray.count
}
    
func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
    return categoriesArray[row]
}

func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    categoryTxt.text = "\(categoriesArray[row])"
}

    
// PICKERVIEW DONE BUTTON
@IBAction func doneButt(sender: AnyObject) {
    hideCatPickerView()
}

    
    
    
    
// MARK: - POST A NEW AD BUTTON
@IBAction func postAdButt(sender: AnyObject) {
    // USER IS NOT LOGGED IN
    if PFUser.currentUser() == nil {
        simpleAlert("You must first login/signup to Post an Ad")
        
    // USER IS LOGGED IN -> CAN POST A NEW AD
    } else {
        let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
        presentViewController(postVC, animated: true, completion: nil)
    }
}

    
    
    
// MARK: - DISMISS KEYBOARD ON TAP
@IBAction func dismissKeyboardOnTap(sender: UITapGestureRecognizer) {
    keywordsTxt.resignFirstResponder()
    whereTxt.resignFirstResponder()
    categoryTxt.resignFirstResponder()
    hideCatPickerView()
}
    
    
    
// MARK: - SHOW/HIDE CATEGORY PICKERVIEW
func showCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height - self.categoryContainer.frame.size.height-44
    }, completion: { (finished: Bool) in  });
}
func hideCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in  });
}
    
    
    
    
// MARK: - SHOW TERMS OF USE
@IBAction func termsOfUseButt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    presentViewController(touVC, animated: true, completion: nil)
}
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
