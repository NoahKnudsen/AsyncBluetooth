//
//  Created by Noah Knudsen on 04/04/2022.
//

import Foundation

@dynamicMemberLookup
enum Lazy<Wrapped> {
    
    case notInitialised(() -> Wrapped)
    case initialised(Wrapped)
    
    init(_ initialiser: @escaping () -> Wrapped) {
        self = .notInitialised(initialiser)
    }
    
    init(_ value: Wrapped) {
        self = .initialised(value)
    }
    
    subscript<T>(dynamicMember member: KeyPath<Wrapped, T>) -> T? {
        wrapped?[keyPath: member]
    }
}

extension Lazy {

    var wrapped: Wrapped? {
        guard case let .initialised(value) = self else { return nil }
        return value
    }
    
    var isInitialised: Bool {
        if case .initialised = self { return true }
        else { return false }
    }
    
    mutating func initialise() {
        switch self {
        case .notInitialised(let initialiser):
            self = .initialised(initialiser())
        case .initialised: break
        }
    }
}

