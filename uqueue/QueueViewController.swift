//
//  QueueViewController.swift
//  uqueue
//
//  Created by John Rocha on 10/13/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit

class QueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var toPass:[QueuedSong]?
    var currentQueue:[QueuedSong]?
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "songCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentQueue = toPass
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.darkTextColor()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQueue!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let item = currentQueue![indexPath.row]
        cell.textLabel?.text = item.media.title
        cell.textLabel?.textColor = UIColor.whiteColor() 
        return cell
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
