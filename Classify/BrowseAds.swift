/* =======================
 
 - Umbrella -
 
 made by Bring Me©2016
 Andriy Pryvalov
 
 ==========================*/

import UIKit
import Parse

var searchedAdsArray = [PFObject]()



class BrowseAds: UITableViewController {
    
    /* Variables */
    var callTAG = 0
    

    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

     self.title = " Browse Ads"
    
}


 
// MARK: - TABLEVIEW DELEGATES
override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}
override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchedAdsArray.count
}
    
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AdCell", forIndexPath: indexPath) as! AdCell
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = searchedAdsArray[indexPath.row] 
    
    cell.adTitleLabel.text = "\(classifClass[CLASSIF_TITLE]!)"
    cell.adDescrLabel.text = "\(classifClass[CLASSIF_DESCRIPTION]!)"
    cell.addToFavOutlet.tag = indexPath.row
    
    // Get image
    let imageFile = classifClass[CLASSIF_IMAGE1] as? PFFile
    imageFile?.getDataInBackgroundWithBlock ({ (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.adImage.image = UIImage(data:imageData)
    } } })

    
return cell
}
 
// MARK: - SELECTED AN AD -> SHOW IT
override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = searchedAdsArray[indexPath.row]
    
    let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAd") as! ShowSingleAd
    // Pass the Ad Object to the Controller
    showAdVC.singleAdObj = classifClass    
    self.navigationController?.pushViewController(showAdVC, animated: true)
}


    
    
    
// MARK: - ADD AD TO FAVORITES BUTTON
@IBAction func addToFavButt(sender: AnyObject) {
    let button = sender as! UIButton
    
    if PFUser.currentUser() != nil {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = searchedAdsArray[button.tag]
    let favClass = PFObject(className: FAV_CLASS_NAME)
    
    // ADD THIS AD TO FAVORITES
    favClass[FAV_USERNAME] = PFUser.currentUser()?.username!
    favClass[FAV_AD_POINTER] = classifClass
    
    // Saving block
    favClass.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            self.simpleAlert("This Ad has been added to your Favorites!")
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
        
        
        
    // You must login to add Favorites
    } else { simpleAlert("You have to login/signup to favorite ads!") }


}
 
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
