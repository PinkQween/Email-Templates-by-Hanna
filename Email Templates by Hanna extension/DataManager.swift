//
//  DataManager.swift
//  Email Templates by Hanna extension
//
//  Created by Boone, Hanna - Student on 3/16/24.
//

import Foundation
import SwiftUI

class DataManager {
    static let shared = DataManager()
    
    @AppStorage("UserTemplates") var userTemplatesData: Data = Data()
    var userTemplates: [EmailTemplate] = []
    
    private init() {
        loadTemplates()
    }
    
    func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: "UserTemplates") {
            do {
                userTemplates = try JSONDecoder().decode([EmailTemplate].self, from: data)
            } catch {
                print("Error decoding user templates: \(error)")
            }
        }
    }
    
    func saveTemplates() {
        do {
            let data = try JSONEncoder().encode(userTemplates)
            UserDefaults.standard.set(data, forKey: "UserTemplates")
        } catch {
            print("Error encoding user templates: \(error)")
        }
    }
    
    func saveTemplate(_ template: EmailTemplate) {
        userTemplates.append(template)
        saveTemplates()
    }
}
