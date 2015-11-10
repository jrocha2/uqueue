//
//  QueueViewController.swift
//  uqueue
//
//  Created by John Rocha on 10/13/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import CoreData

class QueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var retrievedPlaylists = [NSManagedObject]()
    var currentPlaylist:UserPlaylist?
    var currentlyPlaying:Int?
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "songCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationController!.toolbarHidden = false;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "UqueuePlaylist")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            retrievedPlaylists = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPlaylist!.songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let item = currentPlaylist!.songs[indexPath.row]
        cell.textLabel?.text = item.title
        
        if indexPath.row == currentlyPlaying! {
            cell.textLabel?.textColor = UIColor.greenColor()
        }
        
        return cell
    }
    
    // Brings up options when user presses save at the bottom of viewing current queue
    @IBAction func saveLivePlaylist(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Save This Playlist",
            message: "Save as new playlist or overwrite the current one",
            preferredStyle: .Alert)
        
        let overwriteAction = UIAlertAction(title: "Overwrite",
            style: .Default,
            handler: { (action:UIAlertAction) -> Void in
                self.savePlaylistToCoreData(self.currentPlaylist!)
                
        })
        
        let saveAction = UIAlertAction(title: "Save As",
            style: .Default,
            handler: { (action:UIAlertAction) -> Void in
                let textField = alert.textFields!.first
                let newPlaylist = self.currentPlaylist
                newPlaylist!.title = textField!.text!
                self.savePlaylistToCoreData(newPlaylist!)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(overwriteAction)
        alert.addAction(saveAction);
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // Saves to CoreData where the name of the entity is UqueuePlaylist and the attributes
    // are a String for the title and an array of MPMediaItems for the songs
    func savePlaylistToCoreData(list: UserPlaylist) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("UqueuePlaylist",
            inManagedObjectContext:managedContext)
        
        let playlist = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        playlist.setValue(list.songs, forKey: "songs")
        playlist.setValue(list.title, forKey: "title")
        
        do {
            try managedContext.save()
            retrievedPlaylists.append(playlist)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
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
