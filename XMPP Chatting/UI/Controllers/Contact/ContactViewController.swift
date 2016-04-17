//
//  ContactViewController.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 2/26/16.
//  Copyright © 2016 tutacode. All rights reserved.
//

import UIKit
import XMPPFramework
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit

class ContactViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let interfaceManager = GITInterfaceManager()
    let handler = LoginHandler()
    
    class func createInstance()-> ContactViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ContactViewController") as! ContactViewController
    }
    
    var didSelectUserBlock:(user: XMPPUserCoreDataStorageObject)-> Void = {arg in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoginSuccessfully", name: Notifications.didLoginSuccessfullyNotification, object: nil)
        
        let logoutItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")
        self.navigationItem.leftBarButtonItem = logoutItem
        
        let addItem = UIBarButtonItem(title: "Add Buddy", style: .Plain, target: self, action: "addBuddy")
        self.navigationItem.rightBarButtonItem = addItem
        
        self.title = "Contacts"
        
        // GITKIT
        interfaceManager.delegate = self
        GITClient.sharedInstance().delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        OneRoster.sharedInstance.delegate = self
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkUserLogin()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkUserLogin() {
        if LoginHandler.sharedInstance.isLoggedIn() == false {
            // show login view
            interfaceManager.startSignIn()
            
//            let loginVc = LoginViewController()
//            self.presentViewController(loginVc, animated: true, completion: nil)
        }
    }
    
    func logout() {
        OneMessage.sharedInstance.deleteAllMessages()
        OneChat.sharedInstance.disconnect()
        LoginHandler.sharedInstance.logout()
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        checkUserLogin()
    }
    
    func addBuddy() {
        self.performSegueWithIdentifier(MainStoryboard.Segues.addBuddySegue, sender: nil)
    }
    
    func didLoginSuccessfully() {
        
    }

    func connectToXmppServer() {
        if LoginHandler.sharedInstance.isLoggedIn() && OneChat.sharedInstance.isConnected() == false {
            showHudOnView(self.view, title: "Connecting...")
            OneChat.sharedInstance.connect(username: LoginHandler.sharedInstance.userId!, password: LoginHandler.sharedInstance.password!) { (stream, error) -> Void in
                removeAllHudOnView(self.view)
                if let _ = error {
                    showErrorNotification(description: "Connect to XMPP server failed.")
                } else {
                    //set up online UI
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        showHudOnView(self.view, title: "Connected.", dismissAfter: 2)
                    })
                    
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == MainStoryboard.Segues.showChatView {
            if let user = sender as? XMPPUserCoreDataStorageObject {
                
                var dataSource: AppDataSource!
                
                let chatController = segue.destinationViewController as! MainChatViewController
                if dataSource == nil {
                    dataSource = AppDataSource(sender: user)
                }
                chatController.recipient = user
                chatController.dataSource = dataSource
                chatController.messageSender = dataSource.messageSender
            }
        }
    }

}

extension ContactViewController: GITClientDelegate, GITInterfaceManagerDelegate {
    func client(client: GITClient!, didFinishSignInWithToken token: String!, account: GITAccount!, error: NSError!) {
        if let _ = error {
            // error happen
        } else {
            if let providerId = account.providerID {
                if providerId.containsString("google.com") {
                    startTradingAccessTokenWithProvider(TradeAccessTokenProvider.Google, token: token)
                } else if providerId.containsString("facebook.com") {
                    startTradingAccessTokenWithProvider(TradeAccessTokenProvider.Facebook, token: token)
                }
            } else {
                startTradingAccessTokenWithProvider(TradeAccessTokenProvider.None, token: token)
            }
        }
    }
    func startTradingAccessTokenWithProvider(provider: TradeAccessTokenProvider, token: String) {
        self.handler.startSignInWithSocialProvider(provider, token: token) { (success, error) -> Void in
            if success {
                self.connectToXmppServer()
            } else {
                // call restful api failed, display error
                showErrorNotification(description: "Get XMPP Credential from API failed.")
            }
        }
    }
}

extension ContactViewController: OneRosterDelegate {
    func oneRosterContentChanged(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}

extension ContactViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let secs = OneRoster.buddyList.sections {
            return secs.count
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIden = "ContactCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIden)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIden)
        }
        let user = OneRoster.userFromRosterAtIndexPath(indexPath: indexPath)
        if let nickname = user.nickname where nickname.characters.count > 0 {
            cell!.textLabel!.text = user.nickname
        } else {
            cell!.textLabel!.text = user.displayName
        }
        
        
        cell!.detailTextLabel?.hidden = true
        
        if user.unreadMessages.intValue > 0 {
            cell!.backgroundColor = .orangeColor()
        } else {
            cell!.backgroundColor = .whiteColor()
        }
        
        OneChat.sharedInstance.configurePhotoForCell(cell!, user: user)
        
        return cell!
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections: NSArray? = OneRoster.sharedInstance.fetchedResultsController()!.sections
        
        if section < sections!.count {
            let sectionInfo: AnyObject = sections![section]
            let tmpSection: Int = Int(sectionInfo.name)!
            
            switch (tmpSection) {
            case 0 :
                return "Available"
                
            case 1 :
                return "Away"
                
            default :
                return "Offline"
                
            }
        }
        
        return ""
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let user = OneRoster.userFromRosterAtIndexPath(indexPath: indexPath)
        self.performSegueWithIdentifier(MainStoryboard.Segues.showChatView, sender: user)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections =  OneRoster.buddyList.sections {
            if section < sections.count {
                let sectionInfo: AnyObject = sections[section]
                
                return sectionInfo.numberOfObjects
            }
        }
        
        return 0
    }
}