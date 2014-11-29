import UIKit

let masterDomain = "htapp.ldseo.com"
let masterPath = "http://" + masterDomain + "/"

let APIVersion = masterPath + "API/0.9/"

let DOCUMENTSDIR = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

let defaults = NSUserDefaults.standardUserDefaults()

var appDelegate: HTAppDelegate!
var storyboard: UIStoryboard!

@UIApplicationMain class HTAppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate
{
    var window: UIWindow?

    var username: String?     // Username if set
    var access_token: String? // Access token if there has been successful auth

    var splitViewController: UISplitViewController!

    var loginViewController: HTLoginViewController!
    var masterViewController: MasterViewController!

    var dashboardInformation = NSMutableDictionary()

    class func keychainQuery( service: String, account: String ) -> NSMutableDictionary
    {
        var md = NSMutableDictionary()

        md[kSecClass as String]       = kSecClassGenericPassword as String
        md[kSecAttrGeneric as String] = "OAuth2"
        md[kSecAttrAccount as String] = account
        md[kSecAttrService as String] = service

        return md
    }

    func doLogout()
    {
        removeAccessToken()
        showLoginWindow()
        loginViewController.primeForLogin()

//        if( !isIPad ){ masterNavController.popToRootViewControllerAnimated(false) }

//        masterViewController.doLogout()
    }
    
    func APICall( call: String, args: AnyObject?, completion: ((NSData?, NSURLResponse?, NSError?) -> Void)? ) -> Bool
    {
        if let at = access_token
        {
            if let endpoint = NSURL(string: APIVersion + call)
            {
                var postArguments = "access_token=" + at

                if( args != nil )
                {
                    if( args is String )
                    {
                        postArguments += args as String
                    }
                    else if( args is NSDictionary )
                    {
                        for (key, value) in args as NSDictionary
                        {
                            postArguments += "&"
                            postArguments += key as String
                            postArguments += "="
                            postArguments += value as String
                        }
                    }
                }

                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                {
                    var request = NSMutableURLRequest(URL: endpoint)

                    request.HTTPMethod = "POST"
                    request.HTTPBody = postArguments.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

                    var requestError: NSError?
                    var urlResponse: NSURLResponse?
                    var response = NSURLConnection.sendSynchronousRequest(request, returningResponse: &urlResponse, error: &requestError)

                    if let comp = completion
                    {
                        dispatch_async( dispatch_get_main_queue(),
                        {
                            comp( response, urlResponse, requestError )
                        })
                    }
                })

                return true
            }
        }

        return false
    }

    func getAccessToken() -> String?
    {
        if let at = access_token
        {
            return at
        }
        else if let u = username
        {
            var keychainQuery = HTAppDelegate.keychainQuery(masterDomain, account: u)
            keychainQuery[kSecReturnData as String] = kCFBooleanTrue
            keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne

            var outData: Unmanaged<AnyObject>?
            var status = SecItemCopyMatching(keychainQuery, &outData)

            let opaque = outData?.toOpaque()

            if let op = opaque?
            {
                let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()

                if( (status == 0) && (outData != nil) )
                {
                    access_token = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
                    return access_token
                }
            }
        }

        return nil
    }

    func setAccessToken( token: String, theUsername: String )
    {
        username = theUsername
        defaults.setObject(theUsername, forKey: "username")

        var keychainQuery = HTAppDelegate.keychainQuery(masterDomain, account: theUsername)
        keychainQuery[kSecValueData as String] = token.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

        var status = SecItemAdd(keychainQuery, nil)

        if( status == -25299 )
        {
            var keychainQuery = HTAppDelegate.keychainQuery(masterDomain, account: theUsername)

            status = SecItemUpdate(keychainQuery, NSDictionary(object: token.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, forKey: kSecValueData as String) )
            if( status != errSecSuccess ){ println( "SecItemUpdate failure.") }
        }

        access_token = token
    }

    func removeAccessToken()
    {
        if let u = username
        {
            SecItemDelete( HTAppDelegate.keychainQuery(masterDomain, account: u) )
        }
    }

    func showLoginWindow()
    {
//        window!.makeKeyAndVisible()
//        window!.rootViewController?.presentViewController(loginViewController, animated: false, completion: nil)

    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Override point for customization after application launch.
        appDelegate = self

        storyboard = UIStoryboard(name: "Main", bundle: nil)

        loginViewController  = storyboard?.instantiateViewControllerWithIdentifier("LoginView")  as HTLoginViewController
        splitViewController  = storyboard?.instantiateViewControllerWithIdentifier("SplitView")  as UISplitViewController
        masterViewController = storyboard?.instantiateViewControllerWithIdentifier("MasterView") as MasterViewController

        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count - 1] as UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()

        splitViewController.delegate = self

        username = defaults.objectForKey("username") as String?

        window!.rootViewController = loginViewController
        window!.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool
    {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController
        {
//            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController
//            {
//                if topAsDetailController.detailItem == nil
//                {
//                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
//                    return true
//                }
//            }
        }

        return false
    }
}

