//
//  StoredPlaylists.swift
//  uqueue
//
//  Created by John Rocha on 11/8/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

// This class creates a shared instance of everything in it so that all classes can 
// access the data within
import Foundation

class StoredPlaylists {
    static let sharedInstance = StoredPlaylists()
    
    var userFacebookID = String()
    var userFriendsList = [String:String]()     // [name:uid]
    
    var userPlaylists = [String:UserPlaylist]()
    var playlistNames = [String]()
    
    var lastPlayedPlaylist = String()
}