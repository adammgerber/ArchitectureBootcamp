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
    var destination: () -> AnyView
    
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

struct ProfileView: View {
    
    @State private var path: [AnyDestination] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 40) {
                Button {
                    path.append(AnyDestination(destination: {
                        Text("NEW VALUE!!!!!").any()
                    }))
                } label: {
                    Text("Click me")
                }
                Button {
                    path.append(AnyDestination(destination: {
                        Text("\(12345)").any()
                    }))
                } label: {
                    Text("Click me")
                }
                
                Button {
                    path.append(AnyDestination(destination: {
                        Text("\(true.description)").any()
                    }))
                } label: {
                    Text("Click me")
                }
                
                Button {
                    goToContentView()
                } label: {
                    Text("Click me")
                }
            }
            .navigationDestination(for: AnyDestination.self) { value in
                value.destination()
            }
        }
    }
    
    func goToContentView() {
        let container = DependencyContainer()
        container.register(DataManager.self, service: DataManager(service: MockDataService()))
        container.register(UserManager.self, service: UserManager())

        path.append(AnyDestination(destination: {
            ContentView(
                viewModel: ContentViewModel(interactor: CoreInteractor(container: container))
            )
            .any()
        }))
    }
}

#Preview {
    ProfileView()
}
