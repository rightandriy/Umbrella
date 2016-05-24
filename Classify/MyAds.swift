/* =======================
 
 - Umbrella -
 
 made by Bring Me©2016
 Andriy Pryvalov
 
 ==========================*/

import UIKit
import Parse


class MyAds: UITableViewController {

    /* Variables */
    var classifArray = [PFObject]()
    
    
    
    
override func viewDidAppear(animated: Bool) {
    classifArray.removeAll()
    
    let query = PFQuery(className: CLASSIF_CLASS_NAME)
    query.whereKey(CLASSIF_USER, equalTo: PFUser.currentUser()!)
    query.orderByDescending(CLASSIF_UPDATED_AT)
    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
        if error == nil {
            self.classifArray = objects!
            // Populate the TableView
            self.tableView.reloadData()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}

}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    self.title = "My Ads"
   
}

    
    
    
    
/* MARK: - TABLE VIEW DELEGATES */
override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
}

override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classifArray.count
}

override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyAdCell", forIndexPath: indexPath) as! MyAdCell

    // SHOW ALL YOUR ADS
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = classifArray[indexPath.row]
    
    // Get image
    let imageFile = classifClass[CLASSIF_IMAGE1] as? PFFile
    imageFile?.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                cell.adImage.image = UIImage(data:imageData)
    } } })
    
    
    cell.adTitleLabel.text = "\(classifClass[CLASSIF_TITLE]!)"
    cell.adDescrLabel.text = "\(classifClass[CLASSIF_DESCRIPTION]!)"
    

return cell
}

override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var classifClass = PFObject(className: CLASSIF_CLASS_NAME)
    classifClass = classifArray[indexPath.row]
    
    // Open to Post Controller
    let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
    postVC.postObj = classifClass
    presentViewController(postVC, animated: true, completion: nil)

}

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}
