/* =======================
 
 - Umbrella -
 
 made by Bring Me©2016
 Andriy Pryvalov
 
 ==========================*/

import UIKit
import Parse


class Favorites: UITableViewController {


    /* Variables */
    var favoritesArray = [PFObject]()
    

    

override func viewWillAppear(animated: Bool) {
    if PFUser.currentUser() != nil {
        queryFavAds()
    } else {
        simpleAlert("You must login/signup into your Account to add Favorites")
    }
}
    
override func viewDidLoad() {
        super.viewDidLoad()

    
}

func queryFavAds()  {
    favoritesArray.removeAll()
    
    let query = PFQuery(className: FAV_CLASS_NAME)
    query.whereKey(FAV_USERNAME, equalTo: PFUser.currentUser()!.username!)
    query.includeKey(FAV_AD_POINTER)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.favoritesArray = objects!
            
            // Show details (or reload a TableView)
            self.tableView.reloadData()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
}


// MARK: - TABLEVIEW DELEGATES
override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}
override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return favoritesArray.count
}
    
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesCell", forIndexPath: indexPath) as! FavoritesCell
        
        var favClass = PFObject(className: FAV_CLASS_NAME)
        favClass = favoritesArray[indexPath.row]
    
        // Get Ads as a Pointer
        var adPointer = favClass[FAV_AD_POINTER] as! PFObject
        do { adPointer = try  adPointer.fetchIfNeeded() } catch {}
    
        cell.adTitleLabel.text = "\(adPointer[CLASSIF_TITLE]!)"
        cell.adDescrLabel.text = "\(adPointer[CLASSIF_DESCRIPTION]!)"
        
        // Get image
        let imageFile = adPointer[CLASSIF_IMAGE1] as? PFFile
        imageFile?.getDataInBackgroundWithBlock ({ (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.adImage.image = UIImage(data:imageData)
        }}})
        
    
return cell
}
    
// MARK: - SELECT AN AD -> SHOW IT
override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var favClass = PFObject(className: FAV_CLASS_NAME)
    favClass = favoritesArray[indexPath.row]

    // Get favorite Ads as a Pointer
    var adPointer = favClass[FAV_AD_POINTER] as! PFObject
    do { adPointer = try  adPointer.fetchIfNeeded() } catch {}

    let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAd") as! ShowSingleAd
    // Pass the Ad Objedt to the Controller
    showAdVC.singleAdObj = adPointer
    self.navigationController?.pushViewController(showAdVC, animated: true)
}

    

// MARK: - REMOVE THIS AD FROM YOUR FAVORITES
override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
}
override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete selected Ad
            var favClass = PFObject(className: FAV_CLASS_NAME)
            favClass = favoritesArray[indexPath.row]
            
            favClass.deleteInBackgroundWithBlock {(success, error) -> Void in
                if error != nil {
                    self.simpleAlert("\(error!.localizedDescription)")
            }}

            // Remove record in favoritesArray and the tableView's row
            self.favoritesArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
}

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
