//
//  TransferViewController.swift
//  xmpp-file-transfer-demo-swift
//
//  Created by Miguel Tejedor on 23/5/17.
//  Copyright © 2017 MiTeGu. All rights reserved.
//

import Foundation
import UIKit
import XMPPFramework
import CocoaLumberjack

class TransferViewController: UIViewController, XMPPOutgoingFileTransferDelegate {
    @IBOutlet weak var inputRecipient: UITextField!
    @IBOutlet weak var inputFilename: UITextField!
    @IBOutlet weak var txtDocumentsDir: UILabel!
    
    
    var fileTransfer: XMPPOutgoingFileTransfer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtDocumentsDir.text = documentsDirectory()
    }
    
    func appDelegate() -> AppDelegate? {
        return (UIApplication.shared.delegate as? AppDelegate)
    }
    
    func documentsDirectory() -> String {
        let paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths.last! as! String
    }
    
    
    @IBAction func btnTransferClicked(_ sender: Any) {
        if !(fileTransfer != nil) {
            fileTransfer = XMPPOutgoingFileTransfer(dispatchQueue: DispatchQueue.main)
            fileTransfer?.activate(appDelegate()?.xmppStream)
            fileTransfer?.addDelegate(self, delegateQueue: DispatchQueue.main)
        }
        let recipient: String = inputRecipient.text!
        let filename: String = inputFilename.text!
        
        // do error checking fun stuff...
        let fullPath: String = URL(fileURLWithPath: documentsDirectory()).appendingPathComponent(filename).absoluteString
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: fullPath), options: .alwaysMapped)
            try fileTransfer?.send(data, named: filename, toRecipient: XMPPJID(string: recipient), description: "Baal's Soulstone, obviously.")
        } catch let error as NSError  {
            DDLogVerbose("You messed something up: \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - XMPPOutgoingFileTransferDelegate Methods
    func xmppOutgoingFileTransfer(_ sender: XMPPOutgoingFileTransfer, didFailWithError error: Error?) {
        DDLogInfo("Outgoing file transfer failed with error: " + error.debugDescription)
        let alert = UIAlertController(title: "Error", message: "There was an error sending your file. See the logs.", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func xmppOutgoingFileTransferDidSucceed(_ sender: XMPPOutgoingFileTransfer) {
        DDLogVerbose("File transfer successful.")
        let alert = UIAlertController(title: "Success!", message: "Your file was sent successfully.", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
}
