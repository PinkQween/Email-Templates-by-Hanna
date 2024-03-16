//
//  MailExtension.swift
//  Email Templates by Hanna extension
//
//  Created by Boone, Hanna - Student on 3/16/24.
//

import MailKit

class MailExtension: NSObject, MEExtension {
    
    
    func handler(for session: MEComposeSession) -> MEComposeSessionHandler {
        // Create a unique instance, since each compose window is separate.
        return ComposeSessionHandler()
    }

    
}

