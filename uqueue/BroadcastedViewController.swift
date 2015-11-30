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
    var ratingHistory = [String:(Int,Int)]()
    var dislikeColor = UIColor(red: 249/255, green: 34/255, blue: 36/255, alpha: 1)
    var likeColor = UIColor(red: 14/255, green: 96/255, blue: 247/255, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "textCell"
    let myRootRef = Firebase(url: "https://uqueue.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
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
        
        let likeButton = MGSwipeButton(title: "Like", backgroundColor: likeColor, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            if self.ratingHistory[songName] == nil {
                self.ratingHistory[songName] = (1,0)
                likeRef.setValue(currentLikeCount+1)
            } else if self.ratingHistory[songName]!.0 == 0 {
                self.ratingHistory[songName]!.0 = 1
                likeRef.setValue(currentLikeCount+1)
                
                if self.ratingHistory[songName]!.1 == 1 {
                    self.ratingHistory[songName]!.1 = 0
                    dislikeRef.setValue(currentDislikeCount-1)
                }
            } else {
                self.ratingHistory[songName]!.0 = 0
                likeRef.setValue(currentLikeCount-1)
            }
            
            return true
        })
        
        let dislikeButton = MGSwipeButton(title: "Dislike", backgroundColor: dislikeColor, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            if self.ratingHistory[songName] == nil {
                self.ratingHistory[songName] = (0,1)
                dislikeRef.setValue(currentDislikeCount+1)
            } else if self.ratingHistory[songName]!.1 == 0 {
                self.ratingHistory[songName]!.1 = 1
                dislikeRef.setValue(currentDislikeCount+1)
                
                if self.ratingHistory[songName]!.0 == 1 {
                    self.ratingHistory[songName]!.0 = 0
                    likeRef.setValue(currentLikeCount-1)
                }
            } else {
                self.ratingHistory[songName]!.1 = 0;
                dislikeRef.setValue(currentDislikeCount-1)
            }
            
            
            return true
        })
        
        cell.rightButtons = [dislikeButton, likeButton]
        cell.titleLabel.text = songName
        cell.likeLabel.text = String(friendSongRatings[row].0)
        cell.likeLabel.textColor = likeColor
        cell.dislikeLabel.text = String(friendSongRatings[row].1)
        cell.dislikeLabel.textColor = dislikeColor
        
        return cell
    }
    
    func parseFirebaseData(snap: FDataSnapshot) {
        friendPlaylist.removeAll()
        friendSongRatings.removeAll()
        
        let playlistSnap = snap.childSnapshotForPath("playlist")
        let orderSnap = snap.childSnapshotForPath("songOrder")
        
        for child in orderSnap.children {
            let songName = child.value as String
            let likesSnap = playlistSnap.childSnapshotForPath(songName).childSnapshotForPath("likes")
            let likes = likesSnap.value as! Int
            let dislikesSnap = playlistSnap.childSnapshotForPath(songName).childSnapshotForPath("dislikes")
            let dislikes = dislikesSnap.value as! Int
            
            friendPlaylist.append(songName)
            friendSongRatings.append((likes,dislikes))
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
