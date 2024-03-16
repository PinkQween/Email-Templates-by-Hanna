//
//  MessageActionHandler.swift
//  Email Templates by Hanna extension
//
//  Created by Boone, Hanna - Student on 3/16/24.
//

import MailKit

class MessageActionHandler: NSObject, MEMessageActionHandler {

    static let shared = MessageActionHandler()
    
    func decideAction(for message: MEMessage, completionHandler: @escaping (MEMessageActionDecision?) -> Void) {
        // The action to take on the message, if any.
        var action: MEMessageActionDecision? = nil
        
        // Check if the subject of the message contains the word Mars.
        // If it does, specify an action to set the background color to red.
        if message.subject.contains("Mars") {
            action = MEMessageActionDecision.action(.setBackgroundColor(.red))
        }
        
        // Always call the completion handler, passing the action
        // to take, or nil if there's no action.
        completionHandler(action)
    }
}
