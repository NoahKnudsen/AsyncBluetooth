//
//  Created by Noah Knudsen on 04/04/2022.
//

import CoreBluetooth

public enum BluetoothError: Error {
    case permissionNotGranted(CBManagerAuthorization)
    case notPoweredOn
    case scanAlreadyInProgress
    case deallocation
    case unexpectedPeripheral(Peripheral)
    case failedToConnect(Peripheral, Error)
    case unknown
}

extension BluetoothError: Equatable {
    
    public static func == (l: BluetoothError, r: BluetoothError) -> Bool {
        
        switch (l,r) {
        case (.permissionNotGranted(let l), .permissionNotGranted(let r)):
            return l == r
            
        case (.notPoweredOn, .notPoweredOn):
            return true
            
        case (.scanAlreadyInProgress, .scanAlreadyInProgress):
            return true
            
        case (.deallocation, .deallocation):
            return true
            
        case (.unexpectedPeripheral(let l), .unexpectedPeripheral(let r)):
            return l == r
            
        case (.failedToConnect(let l, let le), .failedToConnect(let r, let re)):
            return l == r && le.localizedDescription == re.localizedDescription
            
        case (.unknown, .unknown):
            return true
            
        case (.permissionNotGranted,_),
            (.notPoweredOn,_),
            (.scanAlreadyInProgress,_),
            (.deallocation,_),
            (.unexpectedPeripheral,_),
            (.failedToConnect,_),
            (.unknown,_):
                return false
        }
    }
}
