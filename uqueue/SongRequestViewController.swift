//
//  SongRequestViewController.swift
//  uqueue
//
//  Created by John Rocha on 12/3/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell

class SongRequestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var songRequests = [String]()
    let requestsRef = Firebase(url: "https://uqueue.firebaseio.com").childByAppendingPath(StoredPlaylists.sharedInstance.userFacebookID).childByAppendingPath("songRequests")
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        songRequests.removeAll()
    
        requestsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for child in snapshot.children {
                let request = child.value as String
                self.songRequests.append(request)
            }
            self.tableView.reloadData()
        })

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songRequests.count - 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("requestCell", forIndexPath: indexPath) as! MGSwipeTableCell
        let row = indexPath.row
        cell.textLabel?.text = songRequests[row+1]
        
        let deleteButton = MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            self.songRequests.removeAtIndex(row+1)
            self.requestsRef.setValue(self.songRequests)
            tableView.reloadData()
            
            return true
        })
        
        cell.rightButtons = [deleteButton]
        
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
