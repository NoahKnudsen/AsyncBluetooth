//
//  Created by Noah Knudsen on 04/04/2022.
//

import CoreBluetooth
import Combine

@dynamicMemberLookup
public class Peripheral {
   
    public let wrapped: Peripheral_P
    weak var manager: Bluetooth?
    private var bag: Set<AnyCancellable> = []
    
    public init(_ wrapped: Peripheral_P, _ manager: Bluetooth?) {
        self.wrapped = wrapped
        self.manager = manager
    }
    
    public func connect() async throws {
        guard let manager = manager else { throw BluetoothError.deallocation }
        try await manager.connect(to: self)
    }
    
    public subscript<T>(dynamicMember dynamicMember: KeyPath<Peripheral_P, T>) -> T {
        wrapped[keyPath: dynamicMember]
    }
}


extension Peripheral: Equatable {
    
    public static func == (l: Peripheral, r: Peripheral) -> Bool {
        type(of: l.wrapped) == type(of: r.wrapped)
        && l.name == r.name
        && l.state == r.state
    }
    
    public static func == (l: Peripheral, r: Peripheral.Mock) -> Bool {
        guard let l = l.wrapped as? Peripheral.Mock else { return false }
        return l == r
    }
    public static func == (l: Peripheral.Mock, r: Peripheral) -> Bool {
        guard let r = r.wrapped as? Peripheral.Mock else { return false }
        return l == r
    }
}

extension Peripheral {
    
    public class Mock: Peripheral_P, Equatable {
        
        public var identifier: UUID
        public var name: String?
        public var state: CBPeripheralState
         
        public init(
            identifier: UUID = UUID(),
            name: String? = nil,
            state: CBPeripheralState = .disconnected
        ) {
            self.identifier = identifier
            self.name = name
            self.state = state
        }
        
        public static func == (l: Peripheral.Mock, r: Peripheral.Mock) -> Bool {
            l.name == r.name
            && l.state == r.state
        }
    }
}
