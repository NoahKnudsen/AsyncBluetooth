//
//  Created by Noah Knudsen on 04/04/2022.
//

import CoreBluetooth
import Combine

extension Bluetooth {
    
    public class Mock: Manager_P {
        
        public var isScanning: Bool = false
        public var state: CBManagerState = .poweredOn
        public var authorisation: CBManagerAuthorization = .allowedAlways
        
        weak var delegate: Delegate?
        
        public var peripherals: [DiscoveredPeripheral.Mock]
        
        public init(
            isScanning: Bool = false,
            state: CBManagerState = .poweredOn,
            authorisation: CBManagerAuthorization = .allowedAlways,
            peripherals: [DiscoveredPeripheral.Mock] = []
        ) {
            self.isScanning = isScanning
            self.state = state
            self.authorisation = authorisation
            self.peripherals = peripherals
        }
        
        func start(_ delegate: Delegate) {
            self.delegate = delegate
            delegate.didUpdateState.send(state)
            delegate.didUpdateAuthorization.send(authorisation)
        }
    }
}

// MARK: Discovering Peripherals

extension Bluetooth.Mock {
    
    internal func scanForPeripherals(
        withServices serviceUUIDs: [CBUUID]?,
        options: [String : Any]?
    ) {
        isScanning = true
        for mock in peripherals {
            discover(mock)
        }
    }
    
    public func discover(_ discovery: DiscoveredPeripheral.Mock) {
        self.delegate?.didDiscover(
            peripheral: discovery.peripheral,
            advertisementData: discovery.advertisementData,
            rssi: discovery.rssi
        )
    }
    
    public func stopScan() {
        isScanning = false
        delegate?.stopDiscoveryScan()
    }
}


// MARK: Peripheral Connections

extension Bluetooth.Mock {
    
    internal func connect(
        to peripheral: Peripheral,
        options: [String : Any]?
    ) throws {
        guard peripheral.wrapped is Peripheral.Mock else {
            throw BluetoothError.unexpectedPeripheral(peripheral)
        }
        // Call `update(_ peripheral, to state)` to control the timing of connections
    }
    
    public func update(_ peripheral: Peripheral.Mock, to state: CBPeripheralState, error: Error? = nil) {
        peripheral.state = state
        delegate?.didUpdateConnection(to: peripheral, error: error)
    }
}



