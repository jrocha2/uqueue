//
//  QueueViewController.swift
//  uqueue
//
//  Created by John Rocha on 10/13/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData
import Firebase

class QueueViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var myPlayer = MPMusicPlayerController()
    var retrievedPlaylists = [NSManagedObject]()
    var currentPlaylist:UserPlaylist?
    var currentlyPlaying:Int?
    var newSongSelected = false
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "songCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationController!.toolbarHidden = false;
        
        myPlayer.beginGeneratingPlaybackNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateCurrentSong", name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: nil)
        
    }
    
    @IBOutlet weak var navBar: UINavigationItem!
    var currentPlaylistTitle : String!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navBar.title = currentPlaylistTitle
        
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController!.toolbarHidden = true
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
        }else{
            cell.textLabel?.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        var newQueue = [MPMediaItem]()
        
        for (var i = row; i < currentPlaylist!.songs.count; i++) {
            newQueue.append(currentPlaylist!.songs[i])
        }
        for (var i = 0; i < row; i++) {
            newQueue.append(currentPlaylist!.songs[i])
        }
        
        currentlyPlaying = row
        newSongSelected = true
        myPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: newQueue))
        myPlayer.play()
        
    }
    
    func updateCurrentSong() {
        if newSongSelected {
            newSongSelected = false
        }else{
            if currentlyPlaying == currentPlaylist!.songs.count-1 {
                currentlyPlaying = 0
            }else{
                currentlyPlaying!++
            }
        }
        tableView.reloadData()
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
    
    @IBAction func broadcastButtonPressed(sender: AnyObject!) {
        broadcastPlaylist(currentPlaylist!)
        let alertController = UIAlertController(title: nil, message:
            "Your playlist is now broadcasting!" , preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Yay!", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func broadcastPlaylist(list: UserPlaylist) {
        let myRootRef = Firebase(url: "https://uqueue.firebaseio.com")
        let userRef = myRootRef.childByAppendingPath(StoredPlaylists.sharedInstance.userFacebookID)
        
        
        var songsWithRatings = [String : [String:Int]]()
        var songOrder = [String]()
        
        for song in currentPlaylist!.songs {
            var title = song.title!
            title = title.stringByReplacingOccurrencesOfString("/", withString: "-")
            title = title.stringByReplacingOccurrencesOfString(".", withString: "")
            title = title.stringByReplacingOccurrencesOfString("#", withString: " ")
            title = title.stringByReplacingOccurrencesOfString("$", withString: " ")
            title = title.stringByReplacingOccurrencesOfString("[", withString: "(")
            title = title.stringByReplacingOccurrencesOfString("]", withString: ")")
            
            songOrder.append(title)
            songsWithRatings[title] = ["likes" : 0, "dislikes" : 0]
        }
        
        userRef.childByAppendingPath("songOrder").setValue(songOrder)
        userRef.childByAppendingPath("playlist").setValue(songsWithRatings)
    }

    @IBAction func addSong(sender: AnyObject) {
       
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
