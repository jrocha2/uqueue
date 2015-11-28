//
//  AuthenticationViewController.swift
//  uqueue
//
//  Created by John Rocha on 11/22/15.
//  Copyright © 2015 John Rocha and Shawn Fotsch. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase

class AuthenticationViewController: UIViewController {

    let myRootRef = Firebase(url: "https://uqueue.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Facebook authentication
        let facebookLogin = FBSDKLoginManager()
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            if FBSDKAccessToken.currentAccessToken().hasGranted("user_friends") {
                StoredPlaylists.sharedInstance.userFacebookID = "facebook:" + FBSDKAccessToken.currentAccessToken().userID
                getFriends()
            }
        }else{
        
            facebookLogin.logInWithReadPermissions(["user_friends"], fromViewController: self, handler: {
                (facebookResult, facebookError) -> Void in
                
                if facebookError != nil {
                    print("Facebook login failed. Error \(facebookError)")
                } else if facebookResult.isCancelled {
                    print("Facebook login was cancelled.")
                } else {
                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    
                    self.getPermissions(accessToken)
                    
                }
            })
        }
    }
    

    func getPermissions(token: String) {
        self.myRootRef.authWithOAuthProvider("facebook", token: token,
            withCompletionBlock: { error, authData in
                
                if error != nil {
                    print("Login failed. \(error)")
                } else {
                    print("Logged in! \(authData)")
                    StoredPlaylists.sharedInstance.userFacebookID = authData.uid
                    self.getFriends()
                }
        })

    }
    
    
    func getFriends() {
        let fbFriendsRequest = FBSDKGraphRequest(graphPath:"me/friends", parameters: nil);
        fbFriendsRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                
                let friendObjects = result["data"] as! [NSDictionary]
                for friend in friendObjects {
                    StoredPlaylists.sharedInstance.userFriendsList[friend["name"] as! String] = "facebook:" + (friend["id"] as! String)
                }
                print("Friends: \(StoredPlaylists.sharedInstance.userFriendsList)")
                
                self.performSegueWithIdentifier("authSegue", sender: nil)
                
            } else {
                
                print("Error Getting Friends \(error)");
                
            }
        }

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
