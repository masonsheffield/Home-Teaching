import UIKit

class HTLoginViewController : UIViewController
{
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var passwordLabel: UILabel!

    @IBOutlet var loginUsername: UITextField!
    @IBOutlet var loginPassword: UITextField!

    @IBOutlet var loginProgress: UIActivityIndicatorView!

    @IBOutlet var keyboardHeight: NSLayoutConstraint!

    func getInformation()
    {
        var information = NSMutableDictionary()

        // These three API endpoints can potentially be combined into one for convinience when launching the app
        appDelegate.APICall("companionship", args: nil, completion:
        { (response: NSData?, urlResponse: NSURLResponse?, requestError: NSError?) in

            var err: NSError?
            if let resp = NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSArray?
            {
                information["companion"] = resp
            }

            appDelegate.APICall("district", args: nil, completion:
            { (response: NSData?, urlResponse: NSURLResponse?, requestError: NSError?) in

                var err: NSError?
                if let resp = NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSArray?
                {
                    information["district"] = resp
                }

                appDelegate.APICall("assignment", args: nil, completion:
                { (response: NSData?, urlResponse: NSURLResponse?, requestError: NSError?) in

                    var err: NSError?
                    if let resp = NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSArray?
                    {
                        information["assignment"] = resp
                    }

                    appDelegate.dashboardInformation = information

                    self.performSegueWithIdentifier("SplitViewSegue", sender: nil)
                })

            })
        })
    }

    func isLoggingIn( li: Bool )
    {
        usernameLabel.hidden = li
        passwordLabel.hidden = li

        loginUsername.hidden = li
        loginPassword.hidden = li

        if( li ){ loginProgress.startAnimating() }else{ loginProgress.stopAnimating() }
    }

    func primeForLogin(){ if( loginUsername.text == "" ){ loginUsername.becomeFirstResponder() }else{ loginPassword.becomeFirstResponder() } }

    @IBAction func setToPassword(){ loginPassword.becomeFirstResponder() }

    @IBAction func login()
    {
        loginUsername.resignFirstResponder()
        loginPassword.resignFirstResponder()

        isLoggingIn(true)

        var request = NSMutableURLRequest(URL: NSURL(string: "http://htapp.ldseo.com/API/0.9/login")!)

        var postArguments = "username=\(loginUsername.text)&password=\(loginPassword.text)"

        request.HTTPMethod = "POST"
        request.HTTPBody = postArguments.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:
        { (response, data, connectionError) -> Void in

            dispatch_async( dispatch_get_main_queue(),
            {
                let httpResponse = response as NSHTTPURLResponse

                if( (connectionError == nil) && (httpResponse.statusCode == 200) )
                {
                    var err: NSError?
                    var resp = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary

                    self.loginPassword.text = ""

                    appDelegate.setAccessToken(resp["oauth_token"] as String, theUsername: self.loginUsername.text)

                    self.getInformation()
                }
                else
                {
                    var errorMessage = NSString(data: data, encoding: NSUTF8StringEncoding)
                    var alert = UIAlertController(title: "Login Failed", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    self.isLoggingIn(false)
                    self.primeForLogin()
                }
            })

        })
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        loginUsername.text = appDelegate.username

        if( (appDelegate.username != nil) && (appDelegate.getAccessToken() != nil ) )
        {
            isLoggingIn(true)

            getInformation()
        }
        else
        {
            dispatch_async( dispatch_get_main_queue(),
            {
                self.primeForLogin()
            })
        }
    }

    func keyboardWillShow( notification: NSNotification )
    {
        if let info = notification.userInfo as NSDictionary?
        {
            if let animationDuration = info.objectForKey( UIKeyboardAnimationDurationUserInfoKey ) as Double?
            {
                if let kbFrame = info.objectForKey( UIKeyboardFrameEndUserInfoKey ) as NSValue?
                {
                    self.keyboardHeight.constant = kbFrame.CGRectValue().size.height/2;

                    UIView.animateWithDuration(animationDuration, animations: { self.view.layoutIfNeeded() })
                }
            }
        }
    }
     
    func keyboardWillHide( notification: NSNotification )
    {
        if let info = notification.userInfo as NSDictionary?
        {
            if let animationDuration = info.objectForKey( UIKeyboardAnimationDurationUserInfoKey ) as Double?
            {
                self.keyboardHeight.constant = 0

                UIView.animateWithDuration(animationDuration, animations: { self.view.layoutIfNeeded() })
            }
        }
    }
 
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}