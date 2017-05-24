File Transfer using XMPPFramework
=================================

This application is merely a brief demo of how to use the file transfer extension of the XMPPFramework.
This is a simple fork of [xmpp-file-transfer-demo](https://github.com/nplexity/xmpp-file-transfer-demo)


Both incoming file transfers and outgoing file transfers are functional within this demo, but I've left a significant amount of error-handling out, so you'll want to include that in your app.

Server Settings
===============

In order for SOCKS5 to work properly, your server must be configured to handle proxy connections.  I've only tested this using **ejabberd**, but these are the `mod_proxy65` settings I used:

```
{mod_proxy65,  [
     {ip, {0,0,0,0}},
     {hostname, "myhostnamehere"},
     {port, 7777},
     {access, all},
     {shaper, c2s_shaper}
]},
```

If you're unable to get the proxy functioning, you always have the option to set `disableSOCKS5 = YES`, which will force an IBB transfer instead.  This is slower, but it's very widely supported.

Usage
=====

Incoming File Transfers
-----------------------

Instantiate a new `XMPPIncomingFileTransfer`, activate it, add a delegate, and wait for a file transfer request.

```swift
var xmppIncomingFileTransfer = XMPPIncomingFileTransfer()
xmppIncomingFileTransfer.activate(xmppStream)
xmppIncomingFileTransfer.addDelegate(self, delegateQueue: DispatchQueue.main)
```

Responding to `disco#info` queries and the like are handled for you.  You'll get a delegate call when an SI offer is received, at which point you can decide whether or not you wish to accept.  You can also set `autoAcceptFileTransfers = YES` and you won't need to call `acceptSIOffer:` yourself.

```swift
func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer, didFailWithError error: Error?) {
    DDLogVerbose("Incoming file transfer failed with error: " + error.debugDescription)
}

func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer, didReceiveSIOffer offer: XMPPIQ) {
    DDLogVerbose("Incoming file transfer did receive SI offer. Accepting...")
    sender.acceptSIOffer(offer)
}

func xmppIncomingFileTransfer(_ sender: XMPPIncomingFileTransfer, didSucceedWith data: Data, named name: String) {
    DDLogVerbose("Incoming file transfer did succeed.")
    let paths: [Any] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true
    let fullPath = URL(fileURLWithPath: paths.last as! String).appendingPathComponent(name)
    do {
        try
            data.write(to: fullPath, options: [])
        } catch let error as NSError  {
        DDLogVerbose("Could not sendFile \(error), \(error.userInfo)")
    }
    DDLogVerbose("Data was written to the path: " + fullPath.absoluteString)
}
```

Outgoing File Transfers
-----------------------

To start a new outgoing file transfer, simply create an instance of `XMPPOutgoingFileTransfer`, activate it, add a delegate, and send your data:

```swift
fileTransfer = XMPPOutgoingFileTransfer(dispatchQueue: DispatchQueue.main)
fileTransfer?.activate(appDelegate()?.xmppStream)
fileTransfer?.addDelegate(self, delegateQueue: DispatchQueue.main)

 do {
        let data = try Data(contentsOf: URL(fileURLWithPath: fullPath), options: .alwaysMapped)
        try fileTransfer?.send(data, named: filename, toRecipient: XMPPJID(string: recipient), description: "Baal's Soulstone, obviously.")
    }   
    catch let error as NSError  {
        DDLogVerbose("You messed something up: \(error), \(error.userInfo)")
    }
```

The following delegate calls when get invoked when appropriate:

```swift
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
```

Originally developed by
============

[Jonathon Staff](http://jonathonstaff.com)


Migrated to Swift
============

[Miguel Tejedor](https://github.com/migueltg)


License
=======

    Copyright 2017 Miguel Tejedor

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
