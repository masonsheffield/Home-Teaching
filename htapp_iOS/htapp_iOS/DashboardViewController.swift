import UIKit

class DashboardViewController: UIViewController
{
    @IBOutlet var companionNameLabel:      UILabel!
    @IBOutlet var companionPhoneLabel:     UILabel!
    @IBOutlet var companionEmailLabel:     UILabel!
    @IBOutlet var companionAddressLabel:   UILabel!

    @IBOutlet var companionImage:          UIImageView!

    @IBOutlet var assignmentTableView:     UITableView!

    @IBOutlet var districtLeaderNameLabel: UILabel!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let companion = appDelegate.dashboardInformation["companion"] as NSDictionary?
        {
            if let name = companion["name"] as NSString?
            {
                companionNameLabel.text = name
            }
        }
        else
        {
            companionNameLabel.text = "(No Companion Assigned Yet)"
        }

        if let district = appDelegate.dashboardInformation["district"] as NSDictionary?
        {
            if let districtLeaderName = district["districtLeaderName"] as NSString?
            {
                districtLeaderNameLabel.text = districtLeaderName
            }
        }
        else
        {
            districtLeaderNameLabel.text = "(No District Leader Exists Currently"
        }

        if let assignment = appDelegate.dashboardInformation["assignment"] as NSArray?
        {
            for family in assignment
            {

            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
