//
//  ComposeSessionViewController.swift
//  Email Templates by Hanna extension
//
//  Created by Boone, Hanna - Student on 3/16/24.
//

import MailKit
import SwiftUI
import Combine

class ComposeSessionViewController: MEExtensionViewController, ObservableObject {
    
    // User-defined email templates
    @AppStorage("UserTemplates") var userTemplatesData: Data = Data()
    @Published public var userTemplates: [EmailTemplate] = [] // Use @Published to notify views of changes
    
    
    // Function to update email components with a template
    func updateEmail(with template: EmailTemplate) {
//        email.subject = template.subject ?? ""
//        email.recipients = template.recipients ?? []
//        email.ccRecipients = template.ccRecipients ?? []
//        email.body = template.body ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        loadTemplates()
        setupRootView()
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
        dump(template)
        print(type(of: template))
        userTemplates.append(template)
        dump(userTemplates)
        saveTemplates()
    }
    
    private func setupRootView() {
        let rootView = RootView(controller: self) // Pass a reference to self
        view = NSHostingView(rootView: rootView)
    }
    
    func dismissWindow() {
        // Close the window
        view.window?.close()
    }
}

struct AddTemplateView: View {
    @State private var templateName = ""
    @State private var templateSubject = ""
    @State private var templateRecipients = ""
    @State private var templateCCRecipients = ""
    @State private var templateBody = ""
    @State private var templateThumbnail: NSImage? = nil
    @State public var window: NSWindow
    private var composeSessionController: ComposeSessionViewController
    
    init(window: NSWindow, composeSessionController: ComposeSessionViewController) {
        self.window = window
        self.composeSessionController = composeSessionController
    }
    
    
    // Flag to indicate if an image has been dropped
    @State private var imageDropped: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Template Details")) {
                TextField("Name", text: $templateName)
                TextField("Subject", text: $templateSubject)
                TextField("Recipients", text: $templateRecipients)
                TextField("CC Recipients", text: $templateCCRecipients)
                
                //                HStack(alignment: .leading, content: {
                //                    Text("Body")
                
                TextEditor(text: $templateBody)
                //                })
                
                //                HStack(alignment: .leading, content: {
                //                    Text("Thumbnail")
                
                Rectangle() // Example of a drop target
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .onDrop(of: ["public.image"], isTargeted: nil) { providers -> Bool in
                        guard let item = providers.first else { return false }
                        
                        item.loadObject(ofClass: NSImage.self) { image, error in
                            if let image = image as? NSImage {
                                DispatchQueue.main.async {
                                    templateThumbnail = image
                                    imageDropped = true
                                }
                            }
                        }
                        
                        return true
                    }
                    .overlay {
                        if let image = templateThumbnail {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 250, height: 150)
                                .clipped()
                                .padding()
                                .overlay {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            
                                            ZStack {
                                                Circle()
                                                    .fill(.black)
                                                
                                                Image(systemName: "multiply")
                                                    .foregroundStyle(.white)
                                            }
                                            .opacity(0.8)
                                            .frame(width: 20, height: 20)
                                            .padding([.top, .trailing], 7)
                                            .onTapGesture {
                                                templateThumbnail = nil
                                                imageDropped = false
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                        } else {
                            DragDropView()
                        }
                    }
                //                })
            }
            
            Section {
                Button("Save Template") {
                    saveTemplate()
                }
                .disabled(!imageDropped || templateName.isEmpty) // Disable the button if no image is dropped
            }
        }
        .navigationTitle("Add Template")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    window.close()
                }
            }
        }
        .padding([.bottom, .horizontal])
    }
    
    private func saveTemplate() {
        guard let templateThumbnail = templateThumbnail else {
            // Handle the case where thumbnail is nil
            return
        }
        
        let template = EmailTemplate(name: templateName,
                                     subject: templateSubject,
                                     recipients: templateRecipients.components(separatedBy: ","),
                                     ccRecipients: templateCCRecipients.components(separatedBy: ","),
                                     body: templateBody,
                                     thumbnail: templateThumbnail)
        //        let controller = ComposeSessionViewController()
        composeSessionController.saveTemplate(template)
        window.close()
    }
}

struct DragDropView: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                VStack {
                    Image(systemName: "arrow.up.square.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                    Text("Drag & Drop Image Here")
                        .foregroundColor(.gray)
                }
            )
    }
}

struct RootView: View {
    let updateEmail: (EmailTemplate) -> Void
    @State private var showingAddTemplate = false
    @State private var selectedTemplate: EmailTemplate?
    @ObservedObject var controller: ComposeSessionViewController
    
    init(controller: ComposeSessionViewController) {
        self.updateEmail = { _ in }
        self.controller = controller
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Image(systemName: "plus")
                    .onTapGesture {
                        showingAddTemplate.toggle()
                    }
                
            }
            .padding()
            .onAppear(perform: {
                dump(controller.userTemplates)
            })
            
            // Grid of email templates
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(controller.userTemplates) { template in
                        EmailTemplateView(template: template)
                            .onTapGesture {
                                controller.updateEmail(with: template)
                                controller.dismissWindow()
                            }
                            .frame(width:  175, height: 50)
                    }
                }
                .padding()
            }
        }
        .onAppear(perform: {
            controller.loadTemplates()
        })
        
        .frame(width: 800)
        .frame(minHeight: 10, maxHeight: 1300)
    }
}

struct EmailTemplate: Identifiable, Codable {
    var id = UUID()
    let name: String
    let subject: String?
    let recipients: [String]?
    let ccRecipients: [String]?
    let body: String?
    let thumbnail: NSImage // Assuming this is the thumbnail image
    
    // Implement Codable methods to handle NSImage encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case id, name, subject, recipients, ccRecipients, body, thumbnailData
    }
    
    init(name: String, subject: String? = nil, recipients: [String]? = nil, ccRecipients: [String]? = nil, body: String? = nil, thumbnail: NSImage) {
        self.name = name
        self.subject = subject
        self.recipients = recipients
        self.ccRecipients = ccRecipients
        self.body = body
        self.thumbnail = thumbnail
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.subject = try container.decodeIfPresent(String.self, forKey: .subject)
        self.recipients = try container.decodeIfPresent([String].self, forKey: .recipients)
        self.ccRecipients = try container.decodeIfPresent([String].self, forKey: .ccRecipients)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        
        // Decode thumbnail data and convert it back to NSImage
        let thumbnailData = try container.decode(Data.self, forKey: .thumbnailData)
        guard let thumbnailImage = NSImage(data: thumbnailData) else {
            throw DecodingError.dataCorruptedError(forKey: .thumbnailData,
                                                   in: container,
                                                   debugDescription: "Cannot convert thumbnail data to NSImage")
        }
        self.thumbnail = thumbnailImage
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(subject, forKey: .subject)
        try container.encode(recipients, forKey: .recipients)
        try container.encode(ccRecipients, forKey: .ccRecipients)
        try container.encode(body, forKey: .body)
        
        // Encode thumbnail as data
        guard let thumbnailData = thumbnail.tiffRepresentation else {
            throw EncodingError.invalidValue(thumbnail,
                                             EncodingError.Context(codingPath: container.codingPath,
                                                                   debugDescription: "Cannot convert thumbnail NSImage to Data"))
        }
        try container.encode(thumbnailData, forKey: .thumbnailData)
    }
}

struct EmailTemplateView: View {
    let template: EmailTemplate
    
    var body: some View {
        VStack {
            Image(nsImage: template.thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 250, height: 150)
                .cornerRadius(8)
            
            Text(template.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }
}
