//
//  QueuedSong.swift
//  uqueue
//
//  Created by John Rocha on 10/13/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import MediaPlayer

class QueuedSong: NSObject {

    var upvotes:Int
    var downvotes:Int
    var media:MPMediaItem
    
    init(media: MPMediaItem) {
        self.upvotes = 0
        self.downvotes = 0
        self.media = media
    }
    
}
