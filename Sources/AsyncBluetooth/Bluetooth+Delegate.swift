//
//  Created by Noah Knudsen on 04/04/2022.
//

import CoreBluetooth
import Combine

import Foundation

extension Bluetooth {
    
    class Delegate: NSObject, CBCentralManagerDelegate {
        
        let didUpdateState = CurrentValueSubject<CBManagerState, Never>(.unknown)
        let didUpdateAuthorization = PassthroughSubject<CBManagerAuthorization, Never>()
        
        var discoveryContinutations: [AsyncThrowingStream<DiscoveredPeripheral, Error>.Continuation] = []
        var connectionContinutations: [AsyncStream<ConnectionUpdate>.Continuation] = []
        
        weak var manager: Bluetooth?
    }
}


// MARK: State and Authorization

extension Bluetooth.Delegate {
    
    var state: CBManagerState { didUpdateState.value }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        didUpdateState.send(central.state)
        didUpdateAuthorization.send(CBCentralManager.authorization)
    }
}


// MARK: Discovering Peripherals

extension Bluetooth.Delegate {
    
    func stopDiscoveryScan() {
        for cont in discoveryContinutations {
            cont.finish()
        }
        discoveryContinutations = []
    }
    
    func didDiscover(
        peripheral: Peripheral_P,
        advertisementData: [String : Any],
        rssi: Int
    ) {
        let discovery = DiscoveredPeripheral(
            peripheral: Peripheral(peripheral, manager),
            advertisementData: advertisementData,
            rssi: rssi
        )
        for cont in discoveryContinutations {
            cont.yield(discovery)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        didDiscover(
            peripheral: peripheral,
            advertisementData: advertisementData,
            rssi: RSSI.intValue
        )
    }
}


// MARK: Peripheral Connections

extension Bluetooth.Delegate {
    
    typealias ConnectionUpdate = (peripheral: Peripheral, error: Error?)
    
    func connectionUpdates(build: @escaping () throws -> ()) rethrows -> AsyncStream<ConnectionUpdate> {
        AsyncStream<ConnectionUpdate> { continuation in
            self.connectionContinutations.append(continuation)
            Task { try build() }
        }
    }
    
    func didUpdateConnection(to peripheral: Peripheral_P, error: Error?) {
        let peripheral = Peripheral(peripheral, manager)
        for cont in connectionContinutations {
            cont.yield((peripheral, error))
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        didUpdateConnection(to: peripheral, error: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        didUpdateConnection(to: peripheral, error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        didUpdateConnection(to: peripheral, error: error)
    }
}
