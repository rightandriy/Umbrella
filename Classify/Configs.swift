/* =======================

- Umbrella -

made by Bring Me©2016
Andriy Pryvalov

==========================*/


import Foundation
import UIKit


var APP_NAME = "Umbrella"


var categoriesArray = [
    "Urgent",
    "Top Rated",
    "Drive Me",
    "Bring Me",
    "Help Me",
    "Shopping",
    
    
    
    // Добавление категорий
]



// IMPORTANT: Путь к сайту где хранится sendReply.php
var PATH_TO_PHP_FILE = "http://www.fvimagination.com/classify/"

// IMPORTANT: E-mail
let MY_REPORT_EMAIL_ADDRESS = "report@example.com"

// IMPORTANT: Реклама AdMob INTERSTITIAL's Unit ID
var ADMOB_UNIT_ID = "ca-app-pub-9733347540588953/3763024822"

// HUD View
let hudView = UIView(frame: CGRectMake(0, 0, 80, 80))
let indicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
extension UIViewController {
    func showHUD() {
        hudView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2)
        hudView.backgroundColor = UIColor.darkGrayColor()
        hudView.alpha = 0.9
        hudView.layer.cornerRadius = hudView.bounds.size.width/2
        
        indicatorView.center = CGPointMake(hudView.frame.size.width/2, hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
    }
    func hideHUD() { hudView.removeFromSuperview() }
    
    func simpleAlert(mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }
}




// PARSE KEYS (Для парсинга я использую back4app, но можем поменять,Дьи)
var PARSE_APP_KEY = "kWoY9P6R99yHyn4RYS2Y0tKWfcaXeKugEQNyw42K"
var PARSE_CLIENT_KEY = "02AiOi51h1dkFPYqn9PQzyOV0GdSXBK22p55ryXl"









/*----- DO NOT EDIT THE CODE BELOW! ----*/
/* USER CLASS */
var USER_CLASS_NAME = "User"
var USER_ID = "objectId"
var USER_USERNAME = "username"
var USER_FULLNAME = "fullName"
var USER_PHONE = "phone"
var USER_EMAIL = "email"
var USER_WEBSITE = "website"
var USER_AVATAR = "avatar"

/* CLASSIFIEDS CLASS */
var CLASSIF_CLASS_NAME = "Classifieds"
var CLASSIF_ID = "objectId"
var CLASSIF_USER = "user" // User Pointer
var CLASSIF_TITLE = "title"
var CLASSIF_CATEGORY = "category"
var CLASSIF_ADDRESS = "address" // GeoPoint
var CLASSIF_ADDRESS_STRING = "addressString"
var CLASSIF_PRICE = "price"
var CLASSIF_DESCRIPTION = "description"
var CLASSIF_DESCRIPTION_LOWERCASE = "descriptionLowercase"
var CLASSIF_IMAGE1 = "image1" // File
var CLASSIF_IMAGE2 = "image2" // File
var CLASSIF_IMAGE3 = "image3" // File
var CLASSIF_CREATED_AT = "createdAt"
var CLASSIF_UPDATED_AT = "updatedAt"

/* FAVORITES CLASS */
var FAV_CLASS_NAME = "Favorites"
var FAV_USERNAME = "username"
var FAV_AD_POINTER = "adPointer" // Pointer






