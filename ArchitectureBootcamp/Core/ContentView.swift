//
//  ContentView.swift
//  ArchitectureBootcamp
//
//  Created by Adam Gerber on 04/25/2026.
//

import SwiftUI
import RoutingPro

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
 
 
 
 9. VIPER
 
 Pros:
 - Same as #8 above
 - Decoupled routing from Views
 
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
struct CoreRouter {
    let router: Router
    
    func goToProductView(product: Product) {
        router.showScreen(.push) { _ in
            Text(product.title)
        }
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

// ContentPresenterProtocol, ContentvViewModelDelegate, ContentPresenterDependencies, ContentPresenterInteractor
protocol ContentPresenterInteractor {
    func getProducts() async throws -> [Product]
    func getUser() async throws -> String
}
extension CoreInteractor: ContentPresenterInteractor { }

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


@MainActor
protocol ContentPresenterRouter {
    func goToProductView(product: Product)
}
extension CoreRouter: ContentPresenterRouter { }

@Observable
@MainActor
class ContentPresenter {
    let interactor: ContentPresenterInteractor
    let router: ContentPresenterRouter

    var products: [Product] = []
    
    init(interactor: ContentPresenterInteractor, router: ContentPresenterRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadData() async {
        do {
            let _ = try await interactor.getUser()
            products = try await interactor.getProducts()
        } catch {

        }
    }
    
    func onProductPressed(product: Product) {
        router.goToProductView(product: product)
    }
}

struct ContentView: View {
        
    @State var presenter: ContentPresenter

    var body: some View {
        VStack {
            ForEach(presenter.products) { product in
                Text(product.title)
                    .onTapGesture {
                        presenter.onProductPressed(product: product)
                    }
            }
        }
        .navigationTitle("Content View")
        .padding()
        .task {
            await presenter.loadData()
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

    return RouterView { router in
        ContentView(
            presenter: ContentPresenter(
                interactor: CoreInteractor(container: container),
                router: CoreRouter(router: router)
            )
        )
    }
//    return HomeView(
//        viewModel: HomeViewModel(interactor: CoreInteractor(container: container))
//    )
}
