//
//  ProfileView.swift
//  ArchitectureBootcamp
//
//  Created by Adam Gerber on 25/04/2026.
//

import SwiftUI

//enum NavigationDestinationOption: Hashable {
//    case integerScreen(int: Int)
//    case stringScreen(string: String)
//    case someOtherScreen(bool: Bool)
//}

struct AnyDestination: Hashable {
    let id = UUID().uuidString
    var destination: AnyView
    
    init<T: View>(destination: T) {
        self.destination = AnyView(destination)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension View {
    
    func any() -> AnyView {
        AnyView(self)
    }
}

protocol Router {
    func showScreen<T: View>(@ViewBuilder destination: @escaping (Router) -> T)
    func dismissScreen()
}

struct RouterView<Content: View>: View, Router {
    
    @Environment(\.dismiss) private var dismiss

    @State private var path: [AnyDestination] = []
    
    // Binding to the view stack from previous RouterViews
    @Binding var screenStack: [AnyDestination]
    
    var addNavigationView: Bool
    @ViewBuilder var content: (Router) -> Content
    
    init(
        screenStack: (Binding<[AnyDestination]>)? = nil,
        addNavigationView: Bool = true,
        content: @escaping (Router) -> Content
    ) {
        self._screenStack = screenStack ?? .constant([])
        self.addNavigationView = addNavigationView
        self.content = content
    }

    var body: some View {
        NavigationStackIfNeeded(path: $path, addNavigationView: addNavigationView) {
            content(self)
        }
    }
    
    func showScreen<T: View>(@ViewBuilder destination: @escaping (Router) -> T) {
        let screen = RouterView<T>(
            screenStack: screenStack.isEmpty ? $path : $screenStack,
            addNavigationView: false
        ) { newRouter in
            destination(newRouter)
        }
        
        let destination = AnyDestination(destination: screen)
        
        if screenStack.isEmpty {
            // This means we are in the first RouterView
            path.append(destination)
        } else {
            // This means we are in a secondary RouterView
            screenStack.append(destination)
        }
    }
    
    func dismissScreen() {
        dismiss()
    }
}

/*
 RouterView - @Environment
    ProfileView
        RouterView - @Environment
            SettingsView
                RouterView - @Environment
                    AccountView
 */

struct NavigationStackIfNeeded<Content: View>: View {
    
    @Binding var path: [AnyDestination]
    var addNavigationView: Bool = true
    @ViewBuilder var content: Content
    
    var body: some View {
        if addNavigationView {
            NavigationStack(path: $path) {
                content
                    .navigationDestination(for: AnyDestination.self) { value in
                        value.destination
                    }
            }
        } else {
            content
        }
    }
}


struct ProfileView: View {
            
    let router: Router
    
    var body: some View {
        VStack(spacing: 40) {
            Button {
                router.showScreen { router in
                    SettingsView(router: router)
                }
            } label: {
                Text("Click me")
            }
        }
    }
}

struct SettingsView: View {
    
    let router: Router
    
    var body: some View {
        VStack {
            Text("Settings")
            
            Button {
                router.showScreen { router in
                    AccountView(router: router)
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
    
    let router: Router
    
    var body: some View {
        VStack {
            Text("Account")
            
            Button {
                router.showScreen { router in
                    AccountView(router: router)
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
    RouterView { router in
        ProfileView(router: router)
    }
}
