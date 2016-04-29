//
//  ViewController.swift
//  Chatever
//
//  Created by Wai loon Chong on 4/29/16.
//  Copyright © 2016 derrickCorp. All rights reserved.
//

import UIKit

class ViewController: JSQMessagesViewController {
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    var messages = [JSQMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadMessagesView(){
        self.collectionView?.reloadData()
    }
}

extension ViewController{
    func addDemoMessages(){
        for i in 1...10{
            let sender = (i%2 == 0)? "Server" : self.senderId
            let mesageContent = "Message nr. \(i)"
            let massage = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
        }
        self.reloadMessageView()
    }
    
    func setup(){
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
    }
}


// MARK: -
extension ViewController{
    override func collectionView(collectionVIew: UICollectionView, numberOfItemInSection section: Int)->Int{
        return self.messages.count
    }
}


