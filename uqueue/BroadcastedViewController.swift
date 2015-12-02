//
//  BroadcastedViewController.swift
//  uqueue
//
//  Created by John Rocha on 11/28/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import Firebase
import MGSwipeTableCell

class BroadcastedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var friend:String!
    var friendPlaylist = [String]()
    var friendSongRatings = [(Int,Int)]()
    var friendArtists = [String]()
    var ratingHistory = [String:(Int,Int)]()
    var currentlyPlaying:Int!
    var dislikeColor = UIColor(red: 253/255, green: 59/255, blue: 47/255, alpha: 1)
    var likeColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "songCell"
    let myRootRef = Firebase(url: "https://uqueue.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        var friendName = friend.componentsSeparatedByString(" ")
        navBar.title = friendName[0] + "'s Playlist"
        
        let friendRef = myRootRef.childByAppendingPath(StoredPlaylists.sharedInstance.userFriendsList[friend])
        
        friendRef.observeEventType(.Value, withBlock: { snapshot in
            self.parseFirebaseData(snapshot)
            self.tableView.reloadData()
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendPlaylist.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! SongTableCell
        let row = indexPath.row
        
        let songName = friendPlaylist[row]
        let friendRef = myRootRef.childByAppendingPath(StoredPlaylists.sharedInstance.userFriendsList[friend])
        let likeRef = friendRef.childByAppendingPath("playlist").childByAppendingPath(songName).childByAppendingPath("likes")
        let dislikeRef = friendRef.childByAppendingPath("playlist").childByAppendingPath(songName).childByAppendingPath("dislikes")
        let currentLikeCount = self.friendSongRatings[row].0
        let currentDislikeCount = self.friendSongRatings[row].1
        let likeButton = MGSwipeButton(title: "  Like", icon: UIImage(named: "likeIcon") , backgroundColor: likeColor, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            if self.ratingHistory[songName] == nil {
                self.ratingHistory[songName] = (1,0)
                likeRef.setValue(String(currentLikeCount+1))
            } else if self.ratingHistory[songName]!.0 == 0 {
                self.ratingHistory[songName]!.0 = 1
                likeRef.setValue(String(currentLikeCount+1))
                
                if self.ratingHistory[songName]!.1 == 1 {
                    self.ratingHistory[songName]!.1 = 0
                    dislikeRef.setValue(String(currentDislikeCount-1))
                }
            } else {
                self.ratingHistory[songName]!.0 = 0
                likeRef.setValue(String(currentLikeCount-1))
            }
            
            return true
        })
        
        let dislikeButton = MGSwipeButton(title: "  Dislike", icon: UIImage(named: "dislikeIcon") , backgroundColor: dislikeColor, callback: {
            (sender: MGSwipeTableCell!) -> Bool in

            if self.ratingHistory[songName] == nil {
                self.ratingHistory[songName] = (0,1)
                dislikeRef.setValue(String(currentDislikeCount+1))
            } else if self.ratingHistory[songName]!.1 == 0 {
                self.ratingHistory[songName]!.1 = 1
                dislikeRef.setValue(String(currentDislikeCount+1))
                
                if self.ratingHistory[songName]!.0 == 1 {
                    self.ratingHistory[songName]!.0 = 0
                    likeRef.setValue(String(currentLikeCount-1))
                }
            } else {
                self.ratingHistory[songName]!.1 = 0;
                dislikeRef.setValue(String(currentDislikeCount-1))
            }
            
            
            return true
        })
        
        if currentLikeCount == 0 && currentDislikeCount == 0{
            cell.likeLabel.textColor = UIColor.whiteColor()
            cell.dislikeLabel.textColor = UIColor.whiteColor()
            
        } else{
            cell.dislikeLabel.textColor = dislikeColor
            cell.likeLabel.textColor = likeColor
        }
        
        cell.rightButtons = [dislikeButton, likeButton]
        cell.titleLabel.text = songName
        cell.artistLabel.text = friendArtists[row]
        cell.likeLabel.text = String(friendSongRatings[row].0)
        cell.dislikeLabel.text = String(friendSongRatings[row].1)
        
        if row == currentlyPlaying {
            cell.titleLabel.textColor = UIColor.greenColor()
        }else{
            cell.titleLabel.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    func parseFirebaseData(snap: FDataSnapshot) {
        friendPlaylist.removeAll()
        friendSongRatings.removeAll()
        friendArtists.removeAll()
        
        var stillSharingWithMe = false
        let playlistSnap = snap.childSnapshotForPath("playlist")
        let orderSnap = snap.childSnapshotForPath("songOrder")
        let sharedSnap = snap.childSnapshotForPath("sharedWith")
        let currentlyPlayingSnap = snap.childSnapshotForPath("nowPlaying")
        
        for child in sharedSnap.children {
            if child.value as String == StoredPlaylists.sharedInstance.userFacebookID {
                stillSharingWithMe = true
                break
            }
        }
        
        if stillSharingWithMe {
            currentlyPlaying = currentlyPlayingSnap.value as! Int
            
            for child in orderSnap.children {
                let songName = child.value as String
                let likesSnap = playlistSnap.childSnapshotForPath(songName).childSnapshotForPath("likes")
                print(likesSnap.value)
                let likes = likesSnap.value as! String
                let dislikesSnap = playlistSnap.childSnapshotForPath(songName).childSnapshotForPath("dislikes")
                let dislikes = dislikesSnap.value as! String
                let artistSnap = playlistSnap.childSnapshotForPath(songName).childSnapshotForPath("artist")
                let artist = artistSnap.value as! String
                
                friendPlaylist.append(songName)
                friendSongRatings.append((Int(likes)!,Int(dislikes)!))
                friendArtists.append(artist)
            }
        }else{
            let alertController = UIAlertController(title: nil, message:
            "This playlist is no longer being broadcasted" , preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Back to Main Menu",
                style: .Default) { (action: UIAlertAction) -> Void in
                    self.navigationController!.popViewControllerAnimated(true)
            })
            presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        tableView.reloadData()
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
