//
//  ContentView.swift
//  ArchitectureBootcamp
//
//  Created by Adam Gerber on 04/25/2026.
//

import SwiftUI

/*
 ARCHITECTURE NOTES
 
 1. No Architecture (Vanilla SwiftUI)
 
 - There is no DataManager, Views are responsible for business logic & data logic
 - View holds the array of products
 
Pros:
 - Simplest code
 - Easy to set up, low change for bugs
 
Cons:
 - No seperation between View and Data layers
 - Not testable, mockable, or reusable
 
 
 2. MV Architecture (Vanilla SwiftUI)
 
 - DataManager is shared across the app
 - DataManager is responsible for business logic and data logic
 
 Pros:
 - Less code
 - Easy to reuse business logic
 
 Cons:
 - Tightly coupled the business logic to the data logic
 - "Too easy" to reuse data (other View's can affect each other)
 - DataManager is semi-testable
 
 3. MVC Architecture (Vanilla SwiftUI)
 
 - DataManager is shared across the app
 - Views are responsible for business logic but not data logic
 - View holds the array of products
 
 Pros:
 - DataManager is shared across the application
 - DataManager is testable, mockable, & reusable
 
 Cons:
 - Business logic is not testable
 - Massive View Controller problem
 
 4. MVVM Architecture
 
 - DataManager is shared across the app, but access from the ViewModel
 - ViewModels are responsible for business logic
 - ViewModel holds the array of products
 
 Pros:
 - Seperated the View from the business logic
 - Business logic is now testable
 - View code is much cleaner

 Cons:
 - More difficult to set up and inject dependencies
 - ViewModel lifecycle is outside of View lifecycle (cannot use SwiftUI Property Wrappers)
 
 5. MVVM Architecture + DI Container
 
 Pros:
 - Same as MVVM above, but much easier to manage dependencies
 
 Cons:
 - Adds abstraction to the dependencies (ie. app will crash if dependency is not there)
 
 
 6. MVVM Architecure + Protocols (Interactors)
 
 Pros:
 - Same as MVVM above, but full decouples the dependencies from ViewModel
 - Easiesr to test!
 
 Cons:
 - More work to set up and maintain
 
 
 7. MVVM Architecture + Protocols + Shared Conformance (CoreInteractor)
 
 Pros:
 - Same as #5 above, but easier to setup and maintain
 
 Cons:
 - Single large interactor per module
 
 
 8. MVVM Architecture + Protocols + Shared Conformance + Builder (CoreBuilder)
 
 Pros:
 - Same as #6 above
 - Decoupled routing destinations between views
 - Removed the SwiftUI Environment entirely
 
 Cons:
 - More work to set up and maintain
 
 
 */


@Observable
@MainActor
class UserManager {
    
    func getUser() async throws -> String {
        ""
    }
}

@Observable
@MainActor
class DataManager {
    
    let service: DataService
    
    init(service: DataService) {
        self.service = service
    }
    
    func getProducts() async throws -> [Product] {
        try await service.getProducts()
    }
    
    func getMovies() async throws -> [String] {
        ["MovieA"]
    }
}

@MainActor
struct CoreInteractor {
    let dataManager: DataManager
    let userManager: UserManager
    
    init(container: DependencyContainer) {
        self.dataManager = container.resolve(DataManager.self)!
        self.userManager = container.resolve(UserManager.self)!
    }
    
    func getProducts() async throws -> [Product] {
        try await dataManager.getProducts()
    }
    
    func getMovies() async throws -> [String] {
        try await dataManager.getMovies()
    }
    
    func getUser() async throws -> String {
        try await userManager.getUser()
    }
}

// ContentViewModelProtocol, ContentvViewModelDelegate, ContentViewModelDependencies, ContentViewModelInteractor
protocol ContentViewModelInteractor {
    func getProducts() async throws -> [Product]
    func getUser() async throws -> String
}
extension CoreInteractor: ContentViewModelInteractor { }

protocol HomeViewModelInteractor {
    func getMovies() async throws -> [String]
    func getUser() async throws -> String
}
extension CoreInteractor: HomeViewModelInteractor { }

protocol SettingsViewModelInteractor {
    func getUser() async throws -> String
    func getMovies() async throws -> [String]
}
extension CoreInteractor: SettingsViewModelInteractor { }


@Observable
@MainActor
class ContentViewModel {
    let interactor: ContentViewModelInteractor

    var products: [Product] = []
    
    init(interactor: ContentViewModelInteractor) {
        self.interactor = interactor
    }
    
    func loadData() async {
        do {
            let _ = try await interactor.getUser()
            products = try await interactor.getProducts()
        } catch {

        }
    }
}

struct ContentView: View {
        
    @State var viewModel: ContentViewModel

    var body: some View {
        VStack {
            ForEach(viewModel.products) { product in
                Text(product.title)
            }
        }
        .padding()
        .task {
            await viewModel.loadData()
        }
    }
}

@Observable
@MainActor
class HomeViewModel {
    let interactor: HomeViewModelInteractor

    var movies: [String] = []
    
    init(interactor: HomeViewModelInteractor) {
        self.interactor = interactor
    }
    
    func loadData() async {
        do {
            let _ = try await interactor.getUser()
            movies = try await interactor.getMovies()
        } catch {

        }
    }
}

struct HomeView: View {
    
    @State var viewModel: HomeViewModel

    var body: some View {
        VStack {
            ForEach(viewModel.movies, id: \.self) { movie in
                Text(movie)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .task {
            await viewModel.loadData()
        }
    }
}

@MainActor
class DependencyContainer {
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }
    
    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }
}

#Preview {
    let container = DependencyContainer()
    container.register(DataManager.self, service: DataManager(service: MockDataService()))
    container.register(UserManager.self, service: UserManager())

    return ContentView(
        viewModel: ContentViewModel(interactor: CoreInteractor(container: container))
    )
//    return HomeView(
//        viewModel: HomeViewModel(interactor: CoreInteractor(container: container))
//    )
}
