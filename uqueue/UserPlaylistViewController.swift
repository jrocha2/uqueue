//
//  UserPlaylistViewController.swift
//  uqueue
//
//  Created by John Rocha on 11/4/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData
import Firebase

class UserPlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MPMediaPickerControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var retrievedPlaylists = [NSManagedObject]()
    
    let myPicker = MPMediaPickerController(mediaTypes: MPMediaType.Music)
    let textCellIdentifier = "textCell"
    let myRootRef = Firebase(url: "https://uqueue.firebaseio.com")
    var newPlaylistName:String?
    var selectedPlaylist:String?
    var selectedFriend:String?
    var navColor = UIColor(colorLiteralRed: 66, green: 150, blue: 106, alpha: 1)
    
    var friendsCurrentlySharing = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPicker.delegate = self
        myPicker.allowsPickingMultipleItems = true

        tableView.dataSource = self
        tableView.delegate = self
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
        
        for item in retrievedPlaylists {
            let title = item.valueForKey("title") as? String
            let songs = item.valueForKey("songs") as? [MPMediaItem]
            StoredPlaylists.sharedInstance.playlistNames.append(title!)
            StoredPlaylists.sharedInstance.userPlaylists[title!] = UserPlaylist(name: title!, contents: songs!)
        }
        
        updateBroadcastingFriends()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return StoredPlaylists.sharedInstance.userPlaylists.count
        }else{
            return friendsCurrentlySharing.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let row = indexPath.row
        
        if indexPath.section == 0 {
            cell.textLabel?.text = StoredPlaylists.sharedInstance.playlistNames[row]
        } else {
            let friendID = friendsCurrentlySharing[row]
            for friend in StoredPlaylists.sharedInstance.userFriendsList {
                if friend.1 == friendID {
                    cell.textLabel?.text = friend.0
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Playlists"
        }else{
            return "Friends Broadcasting"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        if indexPath.section == 0 {
            selectedPlaylist = cell.textLabel!.text
            performSegueWithIdentifier("selectedPlaylist", sender: nil)
        }else{
            selectedFriend = cell.textLabel?.text
            performSegueWithIdentifier("selectedFriend", sender: nil)
        }
    }
    
    @IBAction func addPlaylist(sender: UIBarButtonItem) {
        
        // Create popup window asking for playlist name
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "New Playlist", message:  "Enter a playlist name below", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField : UITextField!) in textField.placeholder = "My New Playlist"})
        
        let action = UIAlertAction(title: "Done",
            style: UIAlertActionStyle.Default,
            handler: {
                (paramAction:UIAlertAction!) in
                if let textFields = alertController?.textFields{
                    let theTextFields = textFields as [UITextField]
                    let enteredText = theTextFields[0].text
                    self.newPlaylistName = enteredText
                    
                    // Open music picker
                    self.presentViewController(self.myPicker, animated: true, completion: nil)
                }
            })
        
        alertController?.addAction(action)
        self.presentViewController(alertController!, animated: true, completion: nil)
        // End popup window code
    }
    
    // Called when items chosen in Music Picker and stores
    func mediaPicker(myPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
            var songArray = [MPMediaItem]()
            for item in mediaItemCollection.items as [MPMediaItem] {
                    songArray.append(item)
            }
            
            let newPlaylist = UserPlaylist(name: newPlaylistName!, contents: songArray)
            StoredPlaylists.sharedInstance.playlistNames.append(newPlaylistName!)
            StoredPlaylists.sharedInstance.userPlaylists[newPlaylistName!] = newPlaylist
            
            savePlaylistToCoreData(newPlaylist)
            
            myPicker.dismissViewControllerAnimated(true, completion: nil)
            tableView.reloadData()
    }
    
    // Called to cancel the Media Picker
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "selectedPlaylist" {
            let svc = segue.destinationViewController as! CurrentSongViewController
            svc.currentPlaylistName = selectedPlaylist
        } else if segue.identifier == "selectedFriend" {
            let svc = segue.destinationViewController as! BroadcastedViewController
            svc.friend = selectedFriend
        }
        
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
    
    func updateBroadcastingFriends() {
        var newFriends = [String]()
        var friendCount = 0
        
        for friend in StoredPlaylists.sharedInstance.userFriendsList {
            friendCount++
            let uid = friend.1
            let friendRef = myRootRef.childByAppendingPath(uid).childByAppendingPath("sharedWith")
            friendRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                for child in snapshot.children {
                    if (child.value as String) == StoredPlaylists.sharedInstance.userFacebookID {
                        newFriends.append(uid)
                    }
                    if friendCount == StoredPlaylists.sharedInstance.userFriendsList.count {
                        self.friendsCurrentlySharing = newFriends
                        self.tableView.reloadData()
                    }
                }
            })
        }

    }
}

// Custom segue allows use of table cell information before segue occurs
class CustomSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController as UIViewController
        let destination = destinationViewController as UIViewController
        source.navigationController?.pushViewController(destination, animated: true)
        
    }
}
