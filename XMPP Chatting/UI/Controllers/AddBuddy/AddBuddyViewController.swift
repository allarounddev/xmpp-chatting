//
//  AddBuddyViewController.swift
//  XMPP Chatting
//
//  Created by victor belenko on 2/29/16.
//  Copyright © 2016 tutacode. All rights reserved.
//

import UIKit
import XMPPFramework

class AddBuddyViewController: BaseViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var chatIdLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Add Buddy by Id"
        self.chatIdLabel.text = LoginHandler.sharedInstance.password
        
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text {
            let username = text + "@" + XMPPServer.host
            OneRoster.sharedInstance.sendBuddyRequestTo(username)
            UIAlertView(title: "Add buddy", message: "Request sent. Wait his confirmation", delegate: self, cancelButtonTitle: "OK").show()
        }
        
        return true
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

