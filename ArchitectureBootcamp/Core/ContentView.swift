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
 
 */


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
}

struct ContentView: View {
    
    @Environment(DataManager.self) private var dataManager
    
    @State private var products: [Product] = []

    var body: some View {
        VStack {
            ForEach(products) { product in
                Text(product.title)
            }
        }
        .padding()
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        do {
            products = try await dataManager.getProducts()
        } catch {

        }
    }
}

#Preview {
    ContentView()
        .environment(DataManager(service: MockDataService()))
}
