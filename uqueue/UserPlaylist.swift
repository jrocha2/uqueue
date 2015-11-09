//
//  UserPlaylist.swift
//  uqueue
//
//  Created by John Rocha on 11/4/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import Foundation
import MediaPlayer

class UserPlaylist: NSObject {
    
    var title:String
    var songs:[MPMediaItem]
    
    init(name: String, contents: [MPMediaItem]) {
        title = name
        songs = contents
    }
    
}
