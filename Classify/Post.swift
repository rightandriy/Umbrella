/* =======================
 
 - Umbrella -
 
 made by Bring Me©2016
 Andriy Pryvalov
 
 ==========================*/


import UIKit
import Parse
import MapKit
import CoreLocation
import AddressBook


class Post: UIViewController,
UIPickerViewDataSource,
UIPickerViewDelegate,
UITextFieldDelegate,
UITextViewDelegate,
CLLocationManagerDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
{

    /* Views */
    @IBOutlet var categoryContainer: UIView!
    @IBOutlet var categoryPickerView: UIPickerView!
    
    @IBOutlet var titlelabel: UILabel!
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var titleTxt: UITextField!
    @IBOutlet var categoryTxt: UITextField!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var addressTxt: UITextField!
    @IBOutlet var descrTxt: UITextView!
    
    @IBOutlet var mapView: MKMapView!

    @IBOutlet var buttonsImage: [UIButton]!
    var buttTAG = Int()
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!

    @IBOutlet var postAdOutlet: UIButton!
    
    @IBOutlet var deleteAdOutlet: UIButton!
    
    
    
    /* Variables */
    var postObj = PFObject(className: CLASSIF_CLASS_NAME)
    var favoritesArray = [PFObject]()
    var locationManager: CLLocationManager!
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    var coordinates: CLLocationCoordinate2D!
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    print("POST OBJ: \(postObj) - \(postObj.objectId)")
    
    
    // Round views corners
    deleteAdOutlet.layer.cornerRadius = 8
    
    
    // Show an Alert in case your not logged in
    if PFUser.currentUser() == nil {
        simpleAlert("You must first login/signup to Post an Ad")
    }
    
    
    // Check if you are about to update an Ad
    if  postObj.objectId != nil {
        titlelabel.text = "Edit your Ad"
        postAdOutlet.setTitle("Update", forState: UIControlState.Normal)
        deleteAdOutlet.hidden = false
        
        showAdDetails()
    } else {
        deleteAdOutlet.hidden = true
    }

    
    // Setup views
    categoryContainer.frame.origin.y = view.frame.size.height
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 800)
    view.bringSubviewToFront(categoryContainer)

    
    // Setup buttons to load Ad images
    for button in buttonsImage {
        button.addTarget(self, action: #selector(buttImageTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
}
    
    

// MARK: - SHOW AD DETAILS
func showAdDetails() {
    
    titleTxt.text = "\(postObj[CLASSIF_TITLE]!)"
    categoryTxt.text = "\(postObj[CLASSIF_CATEGORY]!)"
    priceTxt.text = "\(postObj[CLASSIF_PRICE]!)"
    descrTxt.text = "\(postObj[CLASSIF_DESCRIPTION]!)"
    addressTxt.text = "\(postObj[CLASSIF_ADDRESS_STRING]!)"
    addPinOnMap(addressTxt.text!)
    
    // Get image1
    let imageFile1 = postObj[CLASSIF_IMAGE1] as? PFFile
    imageFile1?.getDataInBackgroundWithBlock ({ (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image1.image = UIImage(data:imageData)
    }}})
    
    // Get image2
    let imageFile2 = postObj[CLASSIF_IMAGE2] as? PFFile
    imageFile2?.getDataInBackgroundWithBlock ({ (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image2.image = UIImage(data:imageData)
    }}})
    
    // Get image3
    let imageFile3 = postObj[CLASSIF_IMAGE3] as? PFFile
    imageFile3?.getDataInBackgroundWithBlock ({ (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image3.image = UIImage(data:imageData)
    }}})

}
    
    
    
    
    
// BUTTON FOR IMAGES
func buttImageTapped(sender: UIButton) {
    let button = sender as UIButton
    buttTAG = button.tag
    
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
    
    // OPEN DEVICE'S CAMERA
    if alertView.buttonTitleAtIndex(buttonIndex) == "Take a picture" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
        
    // PICK A PHOTO FROM LIBRARY
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Choose from Library" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        
        
        
    // DELETE AD
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Delete Ad" {
        
            postObj.deleteInBackgroundWithBlock {(success, error) -> Void in
                if error == nil {
                    
                    // Delete an Ad if it's present in Favorites Class too
                    self.favoritesArray.removeAll()
                    let query = PFQuery(className: FAV_CLASS_NAME)
                    query.whereKey(FAV_AD_POINTER, equalTo: self.postObj)
                    query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
                        if error == nil {
                            self.favoritesArray = objects!
                            print("FAV. ARRAY: \(self.favoritesArray)")
                            
                            if self.favoritesArray.count > 0 {
                                for i in 0..<self.favoritesArray.count {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        var favClass = PFObject(className: FAV_CLASS_NAME)
                                        favClass = self.favoritesArray[i]
                            
                                        favClass.deleteInBackgroundWithBlock {(success, error) -> Void in
                                            if error == nil {
                                        }}
                                  })
                                }
                            }
                    }}
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    
}
    
// ImagePicker Delegate
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    
    // Assign Images
    switch buttTAG {
        case 0: image1.image = image;   break
        case 1: image2.image = image;   break
        case 2: image3.image = image;   break
    
    default: break }
    
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
    
// MARK: - SET CURRENT LOCATION BUTTON
@IBAction func setCurrentLocationButt(sender: AnyObject) {
    // Init LocationManager
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
   
    if locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) {
        locationManager.requestAlwaysAuthorization()
     }
    
    
    locationManager.startUpdatingLocation()
}
    
    
    
// MARK: - CORE LOCATION MANAGER -> GET CURRENT LOCATION OF THE USER
func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    simpleAlert("Failed to Get Your Location")
}
func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {

    locationManager.stopUpdatingLocation()
    
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) -> Void in
        
        let placeArray:[CLPlacemark] = placemarks!
        var placemark: CLPlacemark!
        placemark = placeArray[0]
        
        // Street
        let street = placemark.addressDictionary?["Street"] as? String ?? ""
        // City
        let city = placemark.addressDictionary?["City"] as? String ?? ""
        // Zip code
        let zip = placemark.addressDictionary?["ZIP"] as? String ?? ""
        // State
        let state = placemark.addressDictionary?["State"] as? String ?? ""
        // Country
        let country = placemark.addressDictionary?["Country"] as? String ?? ""

        // Show address on addressTxt
        self.addressTxt.text = "\(street), \(zip), \(city), \(state), \(country)"
        // Add a Pin to the Map
        if self.addressTxt!.text! != "" {  self.addPinOnMap(self.addressTxt.text!)  }
        
    })
    
}

    
// MARK: - ADD A PIN ON THE MAP
func addPinOnMap(address: String) {

    if mapView.annotations.count != 0 {
        annotation = mapView.annotations[0] 
        mapView.removeAnnotation(annotation)
    }
    
    // Make a search on the Map
    localSearchRequest = MKLocalSearchRequest()
    localSearchRequest.naturalLanguageQuery = address
    localSearch = MKLocalSearch(request: localSearchRequest)
    
    localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
        // Place not found or GPS not available
        if localSearchResponse == nil  {
            self.simpleAlert("Place not found, or GPS not available")
  
        } else {
            // Add PointAnnonation text and a Pin to the Map
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.titleTxt.text
            self.pointAnnotation.subtitle = self.addressTxt.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
        
            // Store coordinates (to use later while posting the Ad)
            self.coordinates = self.pointAnnotation.coordinate
        
            self.pinView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinView.annotation!)
        
            // Zoom the Map to the location
            self.region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 1000, 1000);
            self.mapView.setRegion(self.region, animated: true)
            self.mapView.regionThatFits(self.region)
            self.mapView.reloadInputViews()
        }
    }
    
}
    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == categoryTxt {
        showCatPickerView()
        titleTxt.resignFirstResponder()
        priceTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
    
return true
}
    
func textFieldDidBeginEditing(textField: UITextField) {
    if textField == categoryTxt {
        showCatPickerView()
        titleTxt.resignFirstResponder()
        priceTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
    
}
func textFieldDidEndEditing(textField: UITextField) {
    // Get address for the Map
    if textField == addressTxt {
        if addressTxt.text != "" {  addPinOnMap(addressTxt.text!)  }
    }
}
    
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == titleTxt   {  categoryTxt.becomeFirstResponder();  hideCatPickerView()  }
    if textField == priceTxt   {  descrTxt.becomeFirstResponder()  }
    if textField == addressTxt {  addressTxt.resignFirstResponder()  }
    
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
    
   
    
    
    
    
// MARK: - POST NEW AD / UPDATE AD BUTTON
@IBAction func postAdButt(sender: AnyObject) {
    showHUD()
    print("POST OBJ (At save/Update): \(postObj)")
    
    
    // POST A NEW AD -----------------------------------------------------------------------
    if PFUser.currentUser() != nil  &&   postObj.objectId == nil {
   
    // Save PFUser as Pointer (if needed)
    postObj[CLASSIF_USER] = PFUser.currentUser()
    
    // Save other data
    postObj[CLASSIF_TITLE] = titleTxt.text
    postObj[CLASSIF_CATEGORY] = categoryTxt.text
    postObj[CLASSIF_PRICE] = priceTxt.text
    postObj[CLASSIF_DESCRIPTION] = descrTxt.text
    postObj[CLASSIF_DESCRIPTION_LOWERCASE] = descrTxt.text!.lowercaseString
    postObj[CLASSIF_ADDRESS_STRING] = addressTxt.text!.lowercaseString
        
    if coordinates != nil {
        let geoPoint = PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude)
        postObj[CLASSIF_ADDRESS] = geoPoint
    }
    
    // Save Image1
    if (image1.image != nil) {
        let imageData = UIImageJPEGRepresentation(image1.image!,0.5)
        let imageFile = PFFile(name:"img1.jpg", data:imageData!)
        postObj[CLASSIF_IMAGE1] = imageFile
    }
    // Save Image2
    if (image2.image != nil) {
        let imageData = UIImageJPEGRepresentation(image2.image!,0.5)
        let imageFile = PFFile(name:"img2.jpg", data:imageData!)
        postObj[CLASSIF_IMAGE2] = imageFile
    }
    // Save Image3
    if (image3.image != nil) {
        let imageData = UIImageJPEGRepresentation(image3.image!,0.5)
        let imageFile = PFFile(name:"img3.jpg", data:imageData!)
        postObj[CLASSIF_IMAGE3] = imageFile
    }
    
    // Saving block
    postObj.saveInBackgroundWithBlock { (success, error) -> Void in
        if error == nil {
            self.simpleAlert("Your Ad has been successfully post!")
            self.dismissViewControllerAnimated(true, completion: nil)
            self.hideHUD()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}


        
        
        
    // UPDATE SELECTED AD ----------------------------------------------------------------------
    } else if PFUser.currentUser() != nil  &&  postObj.objectId != nil {
       
        // Save PFUser as Pointer (if needed)
        postObj[CLASSIF_USER] = PFUser.currentUser()
                
        // Save other data
        postObj[CLASSIF_TITLE] = self.titleTxt.text
        postObj[CLASSIF_CATEGORY] = self.categoryTxt.text
        postObj[CLASSIF_PRICE] = self.priceTxt.text
        postObj[CLASSIF_DESCRIPTION] = self.descrTxt.text
        postObj[CLASSIF_DESCRIPTION_LOWERCASE] = self.descrTxt.text!.lowercaseString
        postObj[CLASSIF_ADDRESS_STRING] = self.addressTxt.text!.lowercaseString
                
        if self.coordinates != nil {
            let geoPoint = PFGeoPoint(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude)
            postObj[CLASSIF_ADDRESS] = geoPoint
        }
                
        // Save Image1
        if (self.image1.image != nil) {
            let imageData = UIImageJPEGRepresentation(self.image1.image!,0.5)
            let imageFile = PFFile(name:"img1.jpg", data:imageData!)
            postObj[CLASSIF_IMAGE1] = imageFile
        }
        // Save Image2
        if (self.image2.image != nil) {
            let imageData = UIImageJPEGRepresentation(self.image2.image!,0.5)
            let imageFile = PFFile(name:"img2.jpg", data:imageData!)
            postObj[CLASSIF_IMAGE2] = imageFile
        }
        // Save Image3
        if (self.image3.image != nil) {
            let imageData = UIImageJPEGRepresentation(self.image3.image!,0.5)
            let imageFile = PFFile(name:"img3.jpg", data:imageData!)
            postObj[CLASSIF_IMAGE3] = imageFile
        }
                
        // Saving block
        postObj.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                self.simpleAlert("Your Ad has been successfully updated!")
                self.dismissViewControllerAnimated(true, completion: nil)
                self.hideHUD()
                  
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
        
    } // END UPDATE AD
    
}
    
    
// MARK: - DELETE AD BUTTON
@IBAction func deleteAdButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Are you sure you want to delete this Ad?",
    delegate: self,
    cancelButtonTitle: "No",
    otherButtonTitles: "Delete Ad")
    alert.show()
}
 
    
    
// MARK: - CANCEL BUTTON
@IBAction func cancelButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
// MARK: - PICKERVIEW DONE BUTTON
@IBAction func doneButt(sender: AnyObject) {
    hideCatPickerView()
}
    

// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
    titleTxt.resignFirstResponder()
    categoryTxt.resignFirstResponder()
    priceTxt.resignFirstResponder()
    addressTxt.resignFirstResponder()
    descrTxt.resignFirstResponder()
}
    
    
// MARK: - SHOW/HIDE CATEGORY PICKERVIEW
func showCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height - self.categoryContainer.frame.size.height
        }, completion: { (finished: Bool) in  });
}
func hideCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in  });
}
    
    
    


    

    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
