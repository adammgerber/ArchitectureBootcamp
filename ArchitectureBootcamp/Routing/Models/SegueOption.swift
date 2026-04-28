//
//  SegueOption.swift
//  ArchitectureBootcamp
//
//  Created by Adam Gerber on 28/04/2026.
//

enum SegueOption {
    case push, sheet, fullScreenCover
    
    var shouldAddNewNavigationView: Bool {
        switch self {
        case .push:
            return false
        case .sheet, .fullScreenCover:
            return true
        }
    }
}
