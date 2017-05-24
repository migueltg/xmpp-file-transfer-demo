//
//  AppDelegate.swift
//  xmpp-file-transfer-demo-swift
//
//  Created by Miguel Tejedor on 23/5/17.
//  Copyright © 2017 MiTeGu. All rights reserved.
//

import UIKit
import XMPPFramework
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var xmppStream:XMPPStream!
    var xmppRoster:XMPPRoster!
    var xmppRosterStorage:XMPPRosterMemoryStorage!
    var xmppIncomingFileTransfer:XMPPIncomingFileTransfer!
    
    // Yes, this is bad. I'm simply lazy and this is a demo...
    var password:String?
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DDLog.add(DDTTYLogger.sharedInstance, with: DDLogLevel.all)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    deinit {
        self.tearDownStream()
    }
    
    // MARK
    
    func prepareStreamAndLogInWithJID(jid:XMPPJID, password:String){
        DDLogVerbose("Preparing the stream and logging in as " + jid.full())
        xmppStream = XMPPStream()
        xmppStream.myJID = jid
        
        xmppRosterStorage = XMPPRosterMemoryStorage()
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        xmppRoster.autoFetchRoster = true
        
        xmppIncomingFileTransfer = XMPPIncomingFileTransfer()
        
        // Activate all modules
        xmppRoster.activate(xmppStream)
        xmppIncomingFileTransfer.activate(xmppStream)
        
        // Add ourselves as delegate to necessary methods
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppIncomingFileTransfer.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        self.password = password
        do {
            try xmppStream.connect(withTimeout: 30)
            
        } catch let error as NSError  {
            DDLogInfo("Error connecting: " + error.debugDescription);
        }
    }
    
    func tearDownStream(){
        xmppStream.removeDelegate(self)
        xmppIncomingFileTransfer.removeDelegate(self)
        xmppRoster.deactivate()
        xmppIncomingFileTransfer.deactivate()
        xmppStream.disconnect()
        xmppStream = nil
        xmppRoster = nil
        xmppRosterStorage = nil
        xmppIncomingFileTransfer = nil
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        DDLogVerbose("Connected successfully.")
        DDLogVerbose("Logging in as " + sender.myJID.full())
        do {
            try xmppStream.authenticate(withPassword: password)
        } catch let error as NSError  {
            DDLogInfo("Error authenticating: " + error.debugDescription);
        }
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        DDLogVerbose("Authenticated successfully.")
        let presence = XMPPPresence()
        xmppStream.send(presence)
    }
    
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        DDLogInfo("Stream disconnected with error: " + error.debugDescription)
    }
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: XMLElement) {
        DDLogInfo("Authentication failed with error: " + error.debugDescription)
    }
    
    func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer, didFailWithError error: Error?) {
        DDLogVerbose("Incoming file transfer failed with error: " + error.debugDescription)
    }
    
    func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer, didReceiveSIOffer offer: XMPPIQ) {
        DDLogVerbose("Incoming file transfer did receive SI offer. Accepting...")
        sender.acceptSIOffer(offer)
    }
    
    func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer, didSucceedWith data: Data, named name: String) {
        DDLogVerbose("Incoming file transfer did succeed.")
        let paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let fullPath = URL(fileURLWithPath: paths.last as! String).appendingPathComponent(name)
        do {
            try
                data.write(to: fullPath, options: [])
        } catch let error as NSError  {
            DDLogVerbose("Could not sendFile \(error), \(error.userInfo)")
        }
        DDLogVerbose("Data was written to the path: " + fullPath.absoluteString)
    }
}
