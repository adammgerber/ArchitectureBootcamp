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
    func showScreen<T: View>(@ViewBuilder destination: () -> T)
}

struct RouterView<Content: View>: View, Router {
    
    @State private var path: [AnyDestination] = []
    @ViewBuilder var content: (Router) -> Content

    var body: some View {
        NavigationStack(path: $path) {
            content(self)
                .navigationDestination(for: AnyDestination.self) { value in
                    value.destination
                }
        }
    }
    
    func showScreen<T: View>(@ViewBuilder destination: () -> T) {
        let destination = AnyDestination(destination: destination())
        path.append(destination)
    }
}

struct ProfileView: View {
    
    @State private var path: [AnyDestination] = []
    
    var body: some View {
        RouterView { router in
            VStack(spacing: 40) {
                Button {
                    router.showScreen {
                        Color.blue
                            .toolbarVisibility(.hidden, for: .navigationBar)
                    }
                } label: {
                    Text("Click me")
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
