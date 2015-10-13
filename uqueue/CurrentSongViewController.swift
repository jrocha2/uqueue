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
    var currentSong:MPMediaItem?
    var currentQueue:[QueuedSong]?
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPicker.delegate = self
        myPicker.allowsPickingMultipleItems = false
        
        selectSong()
        currentSong = myPlayer.nowPlayingItem
        
        // Makes sure current info stays up to day if song ever changes
        myPlayer.beginGeneratingPlaybackNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateCurrentInfo", name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Choose a song to add to the queue
    @IBAction func chooseButtonPressed() {
        selectSong()
    }
    
    // Skip to next song in the queue
    @IBAction func nextButtonPressed() {
        myPlayer.skipToNextItem()
        popQueue()
        myPlayer.play()
    }
    
    
    // Displays Media Picker
    func selectSong() {
        self.presentViewController(myPicker, animated: true, completion: nil)
    }
    
    // Pops front song off of the queue
    func popQueue() {
        var resultArray = [MPMediaItem]()
        var newQueue = [QueuedSong]()
        for item in currentQueue! {
            resultArray.append(item.media)
            newQueue.append(item)
        }
        if (resultArray.count > 0) {
            resultArray.removeFirst()
            newQueue.removeFirst()
        }
        currentQueue = newQueue
        myPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: resultArray))
    }
    
    // Called when an item is chosen in Media Picker
    func mediaPicker(myPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            var resultArray = [MPMediaItem]()
            var newQueue = [QueuedSong]()
            if currentQueue?.count > 0 {
                for item in currentQueue!{
                    resultArray.append(item.media)
                    newQueue.append(item)
                }
            }
            for item in mediaItemCollection.items as [MPMediaItem] {
                resultArray.append(item)
                newQueue.append(QueuedSong(media: item))
            }
            myPlayer.setQueueWithItemCollection(MPMediaItemCollection(items: resultArray))

            currentQueue = newQueue
       
            currentSong = myPlayer.nowPlayingItem
            myPicker.dismissViewControllerAnimated(true, completion: nil)
            myPlayer.play()
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
