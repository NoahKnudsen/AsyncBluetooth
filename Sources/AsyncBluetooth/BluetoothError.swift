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
