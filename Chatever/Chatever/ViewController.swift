//
//  ViewController.swift
//  Chatever
//
//  Created by Wai loon Chong on 4/29/16.
//  Copyright © 2016 derrickCorp. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import syncano_ios


class ViewController: JSQMessagesViewController {
    
    let channel = SCChannel(name: ChannelName)
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    var messages = [JSQMessage]()
    let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(loginViewControllerIdentifier) as! LoginViewController
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
        self.downloadLatestMessagesFromSyncano()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showLoginViewControllerIfNotLoggedIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadMessagesView(){
        self.collectionView?.reloadData()
    }
}

// MARK: - setup
extension ViewController{
    func addDemoMessages(){
        for i in 1...10{
            let sender = (i%2 == 0) ? "Server" : self.senderId
            let messageContent = "Message nr. \(i)"
            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
        }
        self.reloadMessagesView()
    }
    
    func setup(){
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.channel.delegate = self
        self.channel.subscribeToChannel()
    }
}

/**
*  implement JSQMessagesVC protocols
*/

// MARK: - data source
extension ViewController{
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId){
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}

/**
*  handle button press event
*/

// MARK: - make button functional
extension ViewController{
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.sendMessageToSyncano(message)
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
    }
}

// MARK: - syncano
extension ViewController{
    
    func sendMessageToSyncano(message: JSQMessage){
        let messageToSent = Message()
        messageToSent.text = message.text
        messageToSent.senderId = self.senderId
        messageToSent.channel = ChannelName
        messageToSent.other_permissions = .Full
        messageToSent.saveWithCompletionBlock{error in
            if(error != nil){
                //error!!
            }
        }
    }
    
    func downloadLatestMessagesFromSyncano() {
        Message.please().giveMeDataObjectsWithCompletion { objects, error in
            if let messages = objects as? [Message]! {
                self.messages = self.jsqMessagesFromSyncanoMessages(messages)
                self.finishReceivingMessage()
            }
        }
    }
    
    func jsqMessageFromSyncanoMessage(message: Message) -> JSQMessage {
        let jsqMessage = JSQMessage(senderId: message.senderId, senderDisplayName: message.senderId, date: message.created_at, text: message.text)
        return jsqMessage
    }
    
    func jsqMessagesFromSyncanoMessages(messages: [Message]) -> [JSQMessage] {
        var jsqMessages : [JSQMessage] = []
        for message in messages {
            jsqMessages.append(self.jsqMessageFromSyncanoMessage(message))
        }
        return jsqMessages
    }
}

// MARK: - chat channels
extension ViewController : SCChannelDelegate {
    
    func addMessageFromNotification(notification: SCChannelNotificationMessage) {
        let message = Message(fromDictionary: notification.payload)
        if message.senderId == self.senderId {
            //we don't need to add messages from ourselves
            return
        }
        self.messages.append(self.jsqMessageFromSyncanoMessage(message))
        self.finishReceivingMessage()
    }
    
    func updateMessageFromNotification(notification: SCChannelNotificationMessage) {
        
    }
    
    func deleteMessageFromNotification(notification: SCChannelNotificationMessage) {
        
    }
    
    func chanellDidReceivedNotificationMessage(notificationMessage: SCChannelNotificationMessage!) {
        switch(notificationMessage.action) {
        case .Create:
            self.addMessageFromNotification(notificationMessage)
        case .Delete:
            self.deleteMessageFromNotification(notificationMessage)
        case .Update:
            self.updateMessageFromNotification(notificationMessage)
        default:
            break
        }
    }
}

// MARK: - login logic
extension ViewController: LoginDelegate{
    func didSignUp(){
        self.prepareAppForNewUser()
        self.hideLoginViewController()
    }
    
    func didLogin(){
        self.prepareAppForNewUser()
        self.hideLoginViewController()
    }
    
    func prepareAppForNewUser(){
        self.setupSenderData()
        self.reloadAllMessages()
    
    }
    
    func isLoggedIn() -> Bool {
        let isLoggedIn = (SCUser.currentUser() != nil)
        return isLoggedIn
    }
    
    func logout(){
        SCUser.currentUser()?.logout()
    }
    
    func showLoginViewController(){
        self.presentViewController(self.loginViewController, animated: true){
            
        }
    }
    
    func hideLoginViewController(){
        self.dismissViewControllerAnimated(true){
            
        }
    }
    
    func showLoginViewControllerIfNotLoggedIn(){
        if (self.isLoggedIn() == false){
            self.showLoginViewController()
        }
    }
    
    @IBAction func logoutPressed(sender: UIBarButtonItem){
        self.logout()
        self.showLoginViewControllerIfNotLoggedIn()
    }
}















