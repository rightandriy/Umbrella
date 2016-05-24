/* =======================
 
 - Umbrella -
 
 made by Bring Me©2016
 Andriy Pryvalov
 
 ==========================*/


import UIKit
import Parse
import MapKit
import GoogleMobileAds
import AudioToolbox
import MessageUI


class ShowSingleAd: UIViewController,
UIAlertViewDelegate,
UIScrollViewDelegate,
UITextFieldDelegate,
GADInterstitialDelegate,
MFMailComposeViewControllerDelegate,
MKMapViewDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var adTitleLabel: UILabel!
    
    @IBOutlet var imagesScrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var adDescrTxt: UITextView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet weak var websiteOutlet: UIButton!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var messageTxt: UITextView!
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var phoneTxt: UITextField!
    
    @IBOutlet var sendOutlet: UIButton!
    @IBOutlet weak var phoneCallOutlet: UIButton!
    var reportButt = UIButton()
    
    
    var adMobInterstitial: GADInterstitial!
    
    
    
    /* Variables */
    var singleAdObj = PFObject(className: CLASSIF_CLASS_NAME)
    
    var dataURL = NSData()
    var reqURL = NSURL()
    var request = NSMutableURLRequest()
    var receiverEmail = ""
    var postTitle = ""
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    

    
    
    
    

    
override func viewDidLoad() {
        super.viewDidLoad()
    
    showAdDetails()
    
    
    // Initialize a Report Button
    reportButt = UIButton(type: UIButtonType.Custom)
    reportButt.adjustsImageWhenHighlighted = false
    reportButt.frame = CGRectMake(0, 0, 44, 44)
    reportButt.setBackgroundImage(UIImage(named: "reportButt"), forState: UIControlState.Normal)
    reportButt.addTarget(self, action: #selector(reportButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButt)
    
    
    // Init AdMob interstitial
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
    adMobInterstitial = GADInterstitial(adUnitID: ADMOB_UNIT_ID)
    adMobInterstitial.loadRequest(GADRequest())
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.showInterstitial()
    }
    
    
    // Reset variables for Reply
    receiverEmail = ""
    postTitle = ""
    
    
    // Setup container ScrollView
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 1500)
    
    // Setup images ScrollView
    imagesScrollView.contentSize = CGSizeMake(imagesScrollView.frame.size.width*3, imagesScrollView.frame.size.height)
    image1.frame.origin.x = 0
    image2.frame.origin.x = imagesScrollView.frame.size.width
    image3.frame.origin.x = imagesScrollView.frame.size.width*2
    
    // Round views corners
    sendOutlet.layer.cornerRadius = 8
    phoneCallOutlet.layer.cornerRadius = 8

}
    
    
    
    
    
// MARK: - SHOW AD DETAILS
func showAdDetails() {
    
    // Get Ad Title
    adTitleLabel.text = "\(singleAdObj[CLASSIF_TITLE]!)"
    self.title = "\(singleAdObj[CLASSIF_TITLE]!)"
    
     // Get image1
    let imageFile1 = singleAdObj[CLASSIF_IMAGE1] as? PFFile
    imageFile1?.getDataInBackgroundWithBlock ({ (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image1.image = UIImage(data:imageData)
                self.pageControl.numberOfPages = 1
    } } })
    
    // Get image2
    let imageFile2 = singleAdObj[CLASSIF_IMAGE2] as? PFFile
    imageFile2?.getDataInBackgroundWithBlock ({ (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image2.image = UIImage(data:imageData)
                self.pageControl.numberOfPages = 2
    } } })
    
    // Get image3
    let imageFile3 = singleAdObj[CLASSIF_IMAGE3] as? PFFile
    imageFile3?.getDataInBackgroundWithBlock ({ (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.image3.image = UIImage(data:imageData)
                self.pageControl.numberOfPages = 3
    } } })
    
    // Get Ad Price
    priceLabel.text = "\(singleAdObj[CLASSIF_PRICE]!)"
    
    // Get Ad Description
    adDescrTxt.text = "\(singleAdObj[CLASSIF_DESCRIPTION]!)"
    
    // Get Ad Address
    addressLabel.text = "\(singleAdObj[CLASSIF_ADDRESS_STRING]!)"
    addPinOnMap(addressLabel.text!)

    // Get username
    var userPointer = singleAdObj[CLASSIF_USER] as! PFUser
    do { userPointer = try userPointer.fetchIfNeeded() } catch {}
    usernameLabel.text = userPointer.username!
    
    // Check if user has provided a website
    if userPointer[USER_WEBSITE] != nil { websiteOutlet.setTitle("\(userPointer[USER_WEBSITE]!)", forState: .Normal)
    } else { websiteOutlet.setTitle("N/D", forState: .Normal) }
    
    
    // Check if the user has provided a phone number
    if userPointer[USER_PHONE] == nil { phoneCallOutlet.hidden = true
    } else { phoneCallOutlet.hidden = false }
    
}
    
    
    
// OPEN SELLER'S WEBSITE (IF IT EXISTS)
@IBAction func websiteButt(sender: AnyObject) {
    let butt = sender as! UIButton
    let webStr = "\(butt.titleLabel!.text!)"
    if webStr != "N/D" {
        let webURL = NSURL(string: webStr)
        UIApplication.sharedApplication().openURL(webURL!)
    }
}
 
    
    
    
// MARK: - ADMOB INTERSTITIAL DELEGATES
func showInterstitial() {
    // Show AdMob interstitial
    if adMobInterstitial.isReady {
        adMobInterstitial.presentFromRootViewController(self)
        print("present Interstitial")
    }
}

    
    
//MARK: - ADD A PIN ON THE MAP
func addPinOnMap(address: String) {
    mapView.delegate = self
    
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
                let alert = UIAlertView(title: APP_NAME,
                message: "Place not found, or GPS not available",
                delegate: nil,
                cancelButtonTitle: "Try again" )
                alert.show()
            }
                
            // Add PointAnnonation text and a Pin to the Map
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.adTitleLabel.text
            self.pointAnnotation.subtitle = self.addressLabel.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
                
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

 
    
// MARK: - ADD RIGHT CALLOUT TO OPEN IN IOS MAPS APP
func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Handle custom annotations.
        if annotation.isKindOfClass(MKPointAnnotation) {
            
            // Try to dequeue an existing pin view first.
            let reuseID = "CustomPinAnnotationView"
            var annotView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
            
            if annotView == nil {
                annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                annotView!.canShowCallout = true
                
                // Custom Pin image
                let imageView = UIImageView(frame: CGRectMake(0, 0, 32, 32))
                imageView.image =  UIImage(named: "locationButt")
                imageView.center = annotView!.center
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                annotView!.addSubview(imageView)
                
                // Add a RIGHT CALLOUT Accessory
                let rightButton = UIButton(type: UIButtonType.Custom)
                rightButton.frame = CGRectMake(0, 0, 32, 32)
                rightButton.layer.cornerRadius = rightButton.bounds.size.width/2
                rightButton.clipsToBounds = true
                rightButton.setImage(UIImage(named: "openInMaps"), forState: UIControlState.Normal)
                annotView!.rightCalloutAccessoryView = rightButton
            }
    return annotView
    }
        
return nil
}
    
    
    
// MARK: - OPEN THE NATIVE iOS MAPS APP
func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    annotation = view.annotation
    let coordinate = annotation.coordinate
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
    let mapitem = MKMapItem(placemark: placemark)
    mapitem.name = annotation.title!
    mapitem.openInMapsWithLaunchOptions(nil)
}
    

    
    
    
// MARK: - SCROLLVIEW DELEGATE
func scrollViewDidScroll(scrollView: UIScrollView) {
    // switch pageControl to current page
    let pageWidth = imagesScrollView.frame.size.width
    let page = Int(floor((imagesScrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
    pageControl.currentPage = page
}
    
    
// MARK: - TEXTFIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTxt { emailTxt.becomeFirstResponder() }
    if textField == emailTxt { phoneTxt.becomeFirstResponder() }
    if textField == phoneTxt { phoneTxt.resignFirstResponder() }
        
return true
}
    
    
    
    
// MARK: - SEND REPLY BUTTON
@IBAction func sendReplyButt(sender: AnyObject) {
    var user = singleAdObj[CLASSIF_USER] as! PFUser
    do { user = try user.fetchIfNeeded() } catch { print("error")}
    
    receiverEmail = user.email!
    postTitle = adTitleLabel.text!
    print("\(receiverEmail)")
    
    if messageTxt.text != "" &&
       emailTxt.text != ""  &&
       nameTxt.text != ""
    {
    let strURL = "\(PATH_TO_PHP_FILE)sendReply.php?name=\(nameTxt.text!)&fromEmail=\(emailTxt.text!)&tel=\(phoneTxt.text!)&messageBody=\(messageTxt.text!)&receiverEmail=\(receiverEmail)&postTitle=\(postTitle)"
        reqURL = NSURL(string: strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())! )!
        request = NSMutableURLRequest()
        request.URL = reqURL
        request.HTTPMethod = "GET"
        let connection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        print("REQUEST URL: \(reqURL) - \(connection!.description)")
        
        simpleAlert("Thanks, You're reply has been sent!")
            
    
    // SOME REQUIRED FIELD IS EMPTY...
    } else { simpleAlert("Please fill all the required fields.") }
}
    
 
    
    
// MARK: - PHONE CALL BUTTON
@IBAction func phoneCallButt(sender: AnyObject) {
    var user = singleAdObj[CLASSIF_USER] as! PFUser
    do { user = try user.fetchIfNeeded() } catch { print("error")}
    
    let aURL = NSURL(string: "telprompt://\(user[USER_PHONE]!)")!
    if UIApplication.sharedApplication().canOpenURL(aURL) {
        UIApplication.sharedApplication().openURL(aURL)
    } else {
        simpleAlert("This device can't make phone calls")
    }
}
    
    
    
 
// MARK: - REPORT AD BUTTON
func reportButton(sender:UIButton) {
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients([MY_REPORT_EMAIL_ADDRESS])
    mailComposer.setSubject("Reporting Inappropriate Ad")
    
    mailComposer.setMessageBody("Hello,<br>I am reporting an ad with ID: <strong>\(singleAdObj.objectId!)</strong><br> and Title: <strong>\(singleAdObj[CLASSIF_TITLE]!)</strong><br>since it contains inappropriate contents and violates the Terms of Use of this App.<br><br>Please moderate this post.<br><br>Thank you very much,<br>Regards.", isHTML: true)
    
    if MFMailComposeViewController.canSendMail() {
        presentViewController(mailComposer, animated: true, completion: nil)
    } else {
        simpleAlert("Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.")
    }
}
// Email delegate
func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        var outputMessage = ""
        switch result.rawValue {
            case MFMailComposeResultCancelled.rawValue:  outputMessage = "Mail cancelled"
            case MFMailComposeResultSaved.rawValue:  outputMessage = "Mail saved"
            case MFMailComposeResultSent.rawValue:  outputMessage = "Thanks for reporting this post. We will check it out asap and moderate it"
            case MFMailComposeResultFailed.rawValue:  outputMessage = "Something went wrong with sending Mail, try again later."
        default: break }
    
    simpleAlert(outputMessage)
        
    dismissViewControllerAnimated(false, completion: nil)
}

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
