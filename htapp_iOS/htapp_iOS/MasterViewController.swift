import UIKit

class MasterViewController: UITableViewController
{
    override func awakeFromNib()
    {
        super.awakeFromNib()

        if( UIDevice.currentDevice().userInterfaceIdiom == .Pad )
        {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let split = self.splitViewController
        {
            let controllers = split.viewControllers

            // Dashboard is displayed by default, make sure that things are set as if we just selected it by normal
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
            addNavigationControls( controllers[controllers.count-1].topViewController )
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addNavigationControls( controller: UIViewController )
    {
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        controller.navigationItem.leftItemsSupplementBackButton = true
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if( (segue.identifier == "DashboardSegue") ||
            (segue.identifier == "ProfileSegue"  ) )
        {
            addNavigationControls( (segue.destinationViewController as UINavigationController).topViewController )
        }
    }
}

