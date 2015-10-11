//
//  CurrentSongViewController.swift
//  uqueue
//
//  Created by John Rocha on 10/11/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import MediaPlayer

class CurrentSongViewController: UIViewController {

    let myPlayer = MPMusicPlayerController.systemMusicPlayer()
    var currentSong:MPMediaItem!
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let mediaItems = MPMediaQuery.songsQuery().items
        
        let query = MPMediaQuery.songsQuery()
        let predicate = MPMediaPropertyPredicate(value: "Music", forProperty: MPMediaItemPropertyMediaType)
        query.filterPredicates = NSSet(object: predicate)
            as? Set<MPMediaPredicate>
        
        let mediaCollection = MPMediaItemCollection(items: mediaItems!)
        
        myPlayer.setQueueWithItemCollection(mediaCollection)
        
        myPlayer.play()
        currentSong = myPlayer.nowPlayingItem
        
        //Timer that calls updateCurrentInfo every 0.1 seconds
        _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateCurrentInfo"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
