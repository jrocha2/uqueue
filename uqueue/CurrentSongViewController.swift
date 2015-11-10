//
//  CurrentSongViewController.swift
//  uqueue
//
//  Created by John Rocha on 10/11/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import MediaPlayer

class CurrentSongViewController: UIViewController, MPMediaPickerControllerDelegate {

    let myPlayer = MPMusicPlayerController.systemMusicPlayer()
    let myPicker = MPMediaPickerController(mediaTypes: MPMediaType.Music)
    var currentPlaylistName:String?
    var currentPlaylist:UserPlaylist?
    var modifiedQueue:[MPMediaItem]?
    var currentSong:MPMediaItem?
    
    @IBOutlet weak var playAndPauseButton: UIButton!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPicker.delegate = self
        myPicker.allowsPickingMultipleItems = true
        
        currentPlaylist = StoredPlaylists.sharedInstance.userPlaylists[currentPlaylistName!]
        myPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: currentPlaylist!.songs))
        
        myPlayer.play()
        currentSong = myPlayer.nowPlayingItem
    
        // Makes sure current info stays up to day if song ever changes
        myPlayer.beginGeneratingPlaybackNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateCurrentInfo", name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateCurrentInfo", name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: nil)
        
        myPlayer.pause()
    }
    
    // Choose a song to add to the queue
    @IBAction func chooseButtonPressed() {
        selectSong()
    }
    
    // Skip to next song in the queue
    @IBAction func nextButtonPressed() {
        myPlayer.skipToNextItem()
        myPlayer.play()
    }
    
    @IBAction func previousButtonPressed() {
        myPlayer.skipToPreviousItem()
        myPlayer.play()
    }
    
    @IBAction func playOrPausePressed() {
        if myPlayer.playbackState == MPMusicPlaybackState.Paused {
            playAndPauseButton.setImage(UIImage(named: "pausebutton"), forState: UIControlState.Normal)
            myPlayer.play()
        } else {
            playAndPauseButton.setImage(UIImage(named: "playbutton"), forState: UIControlState.Normal)
            myPlayer.pause()
        }
    }
    
    // Displays Media Picker
    func selectSong() {
        self.presentViewController(myPicker, animated: true, completion: nil)
    }
    
    // Called when an item is chosen in Media Picker
    func mediaPicker(myPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            for item in mediaItemCollection.items {
                currentPlaylist!.songs.append(item)
            }
            myPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: currentPlaylist!.songs))
            
            myPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Called to cancel the Media Picker 
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Keeps the displayed info up to date
    func updateCurrentInfo() {
        currentSong = myPlayer.nowPlayingItem
        trackTitleLabel.text = currentSong?.title
        albumTitleLabel.text = currentSong?.albumTitle
        artistNameLabel.text = currentSong?.artist
        albumImage.image = currentSong?.artwork?.imageWithSize(CGSize(width: 150,height: 150))
        
        if myPlayer.playbackState == MPMusicPlaybackState.Paused {
            playAndPauseButton.setImage(UIImage(named: "playbutton"), forState: UIControlState.Normal)
        } else {
            playAndPauseButton.setImage(UIImage(named: "pausebutton"), forState: UIControlState.Normal)
        }
    }
    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "queueSegue") {
            let svc = segue.destinationViewController as! QueueViewController;
            svc.currentPlaylist = currentPlaylist
            svc.currentlyPlaying = myPlayer.indexOfNowPlayingItem
        }
    }

}
