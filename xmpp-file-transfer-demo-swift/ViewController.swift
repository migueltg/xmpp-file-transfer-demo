//
//  ViewController.swift
//  xmpp-file-transfer-demo-swift
//
//  Created by Miguel Tejedor on 23/5/17.
//  Copyright © 2017 MiTeGu. All rights reserved.
//

import UIKit
import XMPPFramework

class ViewController: UIViewController {
    @IBOutlet weak var inputUsername: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This method should really wait for confirmation that the user was able to
    // log in successfully before proceeding (i.e. use
    // shouldPerformSegueWithIdentifier:sender:, but again, this is a simple
    // demo; you're capable of handling error-checking in your own app.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let username:String = inputUsername.text
        let password:String = inputPassword.text
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.prepareStreamAndLogInWithJID(jid: XMPPJID(string: username) , password: password)
    }
    
}
