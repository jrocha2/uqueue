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
    var loggedIn = false
    
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
        
        if !loggedIn {
        
            facebookLogin.logInWithReadPermissions(["email"], fromViewController: self, handler: {
                (facebookResult, facebookError) -> Void in
                
                if facebookError != nil {
                    print("Facebook login failed. Error \(facebookError)")
                } else if facebookResult.isCancelled {
                    print("Facebook login was cancelled.")
                } else {
                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    
                    self.myRootRef.authWithOAuthProvider("facebook", token: accessToken,
                        withCompletionBlock: { error, authData in
                            
                            if error != nil {
                                print("Login failed. \(error)")
                            } else {
                                print("Logged in! \(authData)")
                                self.loggedIn = true
                                self.performSegueWithIdentifier("authSegue", sender: nil)
                            }
                    })
                }
            })
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
