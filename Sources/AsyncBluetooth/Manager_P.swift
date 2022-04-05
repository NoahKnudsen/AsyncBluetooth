//
//  Created by Noah Knudsen on 04/04/2022.
//

import CoreBluetooth
import Combine

protocol Manager_P {
    
    var isScanning: Bool { get }
    var state: CBManagerState { get }
    var authorisation: CBManagerAuthorization { get }
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?)
    func stopScan()
    func connect(to peripheral: Peripheral, options: [String : Any]?) throws
}

extension CBCentralManager: Manager_P {
    
    var authorisation: CBManagerAuthorization { CBCentralManager.authorization }
    
    func connect(to peripheral: Peripheral, options: [String : Any]? = nil) throws {
        guard let peripheral = peripheral.wrapped as? CBPeripheral else {
            throw BluetoothError.unexpectedPeripheral(peripheral)
        }
        connect(peripheral, options: options)
    }
}

