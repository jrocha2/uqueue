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
    var currentSong:MPMediaItem!
    var currentQueue:MPMediaItemCollection!
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPicker.delegate = self
        myPicker.allowsPickingMultipleItems = false
        
        // This code when would just set the queue to be the entire music library
//        let mediaItems = MPMediaQuery.songsQuery().items
//        let query = MPMediaQuery.songsQuery()
//        let predicate = MPMediaPropertyPredicate(value: "Music", forProperty: MPMediaItemPropertyMediaType)
//        query.filterPredicates = NSSet(object: predicate)
//            as? Set<MPMediaPredicate>
//        let mediaCollection = MPMediaItemCollection(items: mediaItems!)
//        myPlayer.setQueueWithItemCollection(mediaCollection)
        
        selectSong()
        currentSong = myPlayer.nowPlayingItem
        
        //Timer that calls updateCurrentInfo every 0.1 seconds
        _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateCurrentInfo"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseButtonPressed() {
        selectSong()
    }
    
    // Displays Media Picker
    func selectSong() {
        self.presentViewController(myPicker, animated: true, completion: nil)
    }
    
    // Called when an item is chosen in Media Picker
    func mediaPicker(myPicker: MPMediaPickerController,
        didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            myPlayer.setQueueWithItemCollection(mediaItemCollection)
            myPlayer.play()
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
