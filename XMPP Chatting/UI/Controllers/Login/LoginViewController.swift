//
//  LoginViewController.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 2/25/16.
//  Copyright © 2016 tutacode. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Fabric
import TwitterKit


class LoginViewController: UIViewController {

    let handler = LoginHandler.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: Button Actions
    
    @IBAction func loginByFacebook(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) -> Void in
            if let _ = error {
                // authentication failed
                showErrorNotification(description: "Login by Facebook failed.")
            } else if result.isCancelled {
                // user cancel authorization process
                showErrorNotification(description: "Please allow permissions to login")
            } else {
                // login success
                self.startTradingAccessTokenWithProvider(.Facebook, token: result.token.tokenString)
            }
        }
    }
    
    @IBAction func loginByGoogle(sender: AnyObject) {
        
    }
    
    @IBAction func loginByTwitter(sender: AnyObject) {
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil && session?.authToken != nil) {
                print(session?.authToken)
                self.startTradingAccessTokenWithProvider(.Twitter, token: session!.authToken)
            } else {
                print("error: \(error!.localizedDescription)")
                showErrorNotification(description: "Error when signing-in by Twitter")
            }
        }
    }
    
    func startTradingAccessTokenWithProvider(provider: TradeAccessTokenProvider, token: String) {
        self.handler.startSignInWithSocialProvider(provider, token: token) { (success, error) -> Void in
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName(Notifications.didLoginSuccessfullyNotification, object: nil)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                // call restful api failed, display error
                showErrorNotification(description: "Get XMPP Credential from API failed.")
            }
        }
    }
}
/*
extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                //                let userId = user.userID
                let idToken = user.authentication.idToken // Safe to send to the server
                //                let name = user.profile.name
                //                let email = user.profile.email
                // ...
                
                self.startTradingAccessTokenWithProvider(.Google, token: idToken)
            } else {
                print("\(error.localizedDescription)")
                showErrorNotification(description: "User cancel signin")
            }
    }
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
            // ...
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
            self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
*/
