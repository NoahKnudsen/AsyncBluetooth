//
//  Created by Noah Knudsen on 04/04/2022.
//

public struct DiscoveredPeripheral {
    
    public let peripheral: Peripheral
    public let advertisementData: [String: Any]
    public let rssi: Int
    
    public init(
        peripheral: Peripheral,
        advertisementData: [String: Any] = [:],
        rssi: Int
    ) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
}

extension DiscoveredPeripheral {
    
    public struct Mock {
        
        public let peripheral: Peripheral.Mock
        public let advertisementData: [String: Any]
        public let rssi: Int
        
        public init(
            peripheral: Peripheral.Mock,
            advertisementData: [String : Any],
            rssi: Int
        ) {
            self.peripheral = peripheral
            self.advertisementData = advertisementData
            self.rssi = rssi
        }
    }
    
    public init(_ mock: Mock, manager: Bluetooth? = nil) {
        self.peripheral = Peripheral(mock.peripheral, manager)
        self.advertisementData = mock.advertisementData
        self.rssi = mock.rssi
    }
}
