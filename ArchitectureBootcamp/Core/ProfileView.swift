//
//  ProfileView.swift
//  ArchitectureBootcamp
//
//  Created by Adam Gerber on 25/04/2026.
//

import SwiftUI

struct ProfileView: View {
       
    @Environment(\.router) private var router
    
    var body: some View {
        List {
            segueSection
            alertSection
        }
        .navigationTitle("Routing examples")
    }
    
    private var segueSection: some View {
        Section {
            Button {
                router.showScreen(.push) { _ in
                    ProfileView()
                }
            } label: {
                Text("Push")
            }
            Button {
                router.showScreen(.sheet) { _ in
                    ProfileView()
                }
            } label: {
                Text("Sheet")
            }
            Button {
                router.showScreen(.fullScreenCover) { _ in
                    ProfileView()
                }
            } label: {
                Text("Full Screen Cover")
            }
            Button {
                router.dismissScreen()
            } label: {
                Text("Dismiss")
            }
        } header: {
            Text("Segues")
        }
    }
    
    private var alertSection: some View {
        Section {
            Button {
                router.showAlert(.alert, title: "Alert 1", subtitle: "Alert subtitle", buttons: nil)
            } label: {
                Text("Alert")
            }
            Button {
                router.showAlert(.confirmationDialog, title: "Alert 2", subtitle: "Alert subtitle", buttons: {
                    AnyView(
                        Group {
                            Button("Alpha", action: { })
                            Button("Beta", action: { })
                            Button("Gamma", action: { })
                            Button("Delta", action: { })
                        }
                    )
                })
            } label: {
                Text("Confirmation Dialog")
            }
            Button {
                router.dismissAlert()
            } label: {
                Text("Dismiss alert")
            }
        } header: {
            Text("Alerts")
        }
    }
}

struct SettingsView: View {
    
    @Environment(\.router) private var router

    var body: some View {
        VStack {
            Text("Settings")
            
            Button {
                router.showScreen(.push) { _ in
                    AccountView()
                }
            } label: {
                Text("Go forward")
            }
            Button {
                router.dismissScreen()
            } label: {
                Text("Dismiss")
            }
        }
        .navigationTitle("Settings")
    }
}

struct AccountView: View {
    
    @Environment(\.router) private var router

    var body: some View {
        VStack {
            Text("Account")
            
            Button {
                router.showScreen(.push) { _ in
                    AccountView()
                }
            } label: {
                Text("Go forward")
            }
            Button {
                router.dismissScreen()
            } label: {
                Text("Dismiss screen")
            }
        }
        .navigationTitle("Account")
    }
}

#Preview {
    RouterView { _ in
        ProfileView()
    }
}
