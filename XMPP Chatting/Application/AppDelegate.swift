//
//  AppDelegate.swift
//  XMPP Chatting
//
//  Created by Victor Belenko on 2/25/16.
//  Copyright © 2016 tutacode. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Initialize google sign in sign-in
        let gitkitClient = GITClient.sharedInstance()
        gitkitClient.apiKey = "AIzaSyCtOiP3XrcIweA9_i_enljFiagzqPwezwg"
        gitkitClient.widgetURL = "http://localhost?placeholder"
        gitkitClient.providers = [kGITProviderGoogle, kGITProviderFacebook]
        GIDSignIn.sharedInstance().clientID = "115850684003-tgo6pkdi1kheaae55ta1302jaajpfnka.apps.googleusercontent.com"
        
        // twitter login
        Fabric.with([Twitter.self])
        
        startXmpp()
        
        customizeAppearance()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if application.respondsToSelector("setKeepAliveTimeout:handler:") {
            application.setKeepAliveTimeout(600, handler: { () -> Void in
                // Do other keep alive stuff here.
            })
        } else {
            OneChat.stop()
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        OneChat.stop()
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return GITClient.handleOpenURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    private func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = AppStyle.mainColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.window?.tintColor = AppStyle.tintColor
    }
    
    func startXmpp() {
        OneChat.start(true, delegate: nil) { (stream, error) -> Void in
            if let _ = error {
                //handle start errors here
                print("errors from appdelegate")
            } else {
                print("Yayyyy")
                //Activate online UI
            }
        }
    }
}
