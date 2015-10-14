//
//  PlaylistViewController.swift
//  uqueue
//
//  Created by Shawn Fotsch on 10/13/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var tableData = MPMediaQuery.playlistsQuery()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

    self.tableView.reloadData()
    
}


func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    return self.tableData.collections!.count
    
}

func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell     {
    
    let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
    
    let playlist: MPMediaPlaylist = self.tableData.collections![indexPath.row] as! MPMediaPlaylist
    let playlistName = playlist.valueForProperty(MPMediaPlaylistPropertyName) as! NSString
    cell.textLabel?.text = playlistName as String
    
    return cell
}

func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    print("Row \(indexPath.row) selected")
}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
