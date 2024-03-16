//
//  ComposeSessionViewController.swift
//  Email Templates by Hanna extension
//
//  Created by Boone, Hanna - Student on 3/16/24.
//

import MailKit
import SwiftUI

struct AddTemplateView: View {
    @Binding var userTemplates: [EmailTemplate]
    @Binding var showingAddTemplate: Bool
    var onSaveTemplate: (EmailTemplate) -> Void
    
    @State private var templateName = ""
    @State private var templateSubject = ""
    @State private var templateRecipients = ""
    @State private var templateCCRecipients = ""
    @State private var templateBody = ""
    @State private var templateThumbnail = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Template Details")) {
                    TextField("Name", text: $templateName)
                    TextField("Subject", text: $templateSubject)
                    TextField("Recipients", text: $templateRecipients)
                    TextField("CC Recipients", text: $templateCCRecipients)
                    TextEditor(text: $templateBody)
                    TextField("Thumbnail", text: $templateThumbnail)
                }
                
                Section {
                    Button("Save Template") {
                        saveTemplate()
                    }
                }
            }
            .navigationTitle("Add Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddTemplate = false
                    }
                }
            }
        }
    }
    
    private func saveTemplate() {
        let template = EmailTemplate(name: templateName,
                                     subject: templateSubject,
                                     recipients: templateRecipients.components(separatedBy: ","),
                                     ccRecipients: templateCCRecipients.components(separatedBy: ","),
                                     body: templateBody,
                                     thumbnail: templateThumbnail)
        onSaveTemplate(template)
        showingAddTemplate = false
    }
}

class ComposeSessionViewController: MEExtensionViewController {
    // Define your email components
    var recipients: [String] = []
    var ccRecipients: [String] = []
    var subject: String = ""
    var body: String = ""
    
    // User-defined email templates
    @AppStorage("UserTemplates") var userTemplatesData: Data = Data()
    @State var userTemplates: [EmailTemplate] = [] // State to hold user templates
    
    // Function to update email components with a template
    func updateEmail(with template: EmailTemplate) {
        recipients = template.recipients ?? recipients
        ccRecipients = template.ccRecipients ?? ccRecipients
        subject = template.subject ?? subject
        body = template.body ?? body
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if let data = try? JSONDecoder().decode([EmailTemplate].self, from: userTemplatesData) {
            userTemplates = data
        }
        setupRootView()
    }
    
    private func setupRootView() {
        let rootView = RootView(updateEmail: updateEmail, userTemplates: $userTemplates) { template in
            // Closure to handle saving the template
            self.userTemplates.append(template)
        }
        view = NSHostingView(rootView: rootView)
    }
}


//struct RootView: View {
//    let updateEmail: (EmailTemplate) -> Void
//    @State private var showingAddTemplate = false
//    @State private var selectedTemplate: EmailTemplate?
//
//    @Binding var userTemplates: [EmailTemplate]
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(userTemplates) { template in
//                    NavigationLink(destination: TemplateDetailView(template: selectedTemplate!, updateEmail: updateEmail)) {
//                        TemplateRowView(template: template)
//                    }
//                }
//                .onDelete(perform: deleteTemplates)
//            }
//            .navigationTitle("Templates")
//            .toolbar {
//                ToolbarItem(placement: .automatic) {
//                    Button(action: {
//                        showingAddTemplate = true
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//        }
//        .sheet(isPresented: $showingAddTemplate) {
//            AddTemplateView(userTemplates: $userTemplates, showingAddTemplate: $showingAddTemplate)
//        }
//    }
//
//    private func deleteTemplates(at offsets: IndexSet) {
//        userTemplates.remove(atOffsets: offsets)
//    }
//}

struct RootView: View {
    let updateEmail: (EmailTemplate) -> Void
    @State private var showingAddTemplate = false
    @State private var selectedTemplate: EmailTemplate?
    
    @Binding var userTemplates: [EmailTemplate]
    
    // Closure to handle saving the template
    let onSaveTemplate: (EmailTemplate) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Image(systemName: "plus")
                    .onTapGesture {
                        showingAddTemplate.toggle()
                    }
            }
            
            
            
            Spacer()
        }
        .onChange(of: showingAddTemplate) {
            if showingAddTemplate {
                // If showingAddTemplate is true, create a new window for AddTemplateView
                let newWindow = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                    styleMask: [.titled, .closable, .resizable],
                    backing: .buffered, defer: false
                )
                newWindow.center()
                newWindow.setIsVisible(true)
                newWindow.contentView = NSHostingView(rootView: AddTemplateView(
                    userTemplates: $userTemplates,
                    showingAddTemplate: $showingAddTemplate,
                    onSaveTemplate: onSaveTemplate
                )
                .frame(minWidth: 400, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
                )
            }
        }
        .frame(width: 350)
        .frame(minHeight: 10, maxHeight: 400)
        //        .frame(width: 300)
        //        .frame(maxHeight: 400)
        .padding()
    }
    
    private func deleteTemplates(at offsets: IndexSet) {
        userTemplates.remove(atOffsets: offsets)
    }
}

struct EmailTemplate: Identifiable, Codable {
    var id = UUID()
    let name: String
    let subject: String?
    let recipients: [String]?
    let ccRecipients: [String]?
    let body: String?
    let thumbnail: String // Assuming this is a filename of the thumbnail image
}
