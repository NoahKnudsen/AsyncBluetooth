//
//  Created by Noah Knudsen on 05/04/2022.
//

import AsyncBluetooth
import CoreBluetooth

final class PublicAPIExamples {
    
    func example_discoverUsingForLoopAndConnect() async throws {
        
        let bluetooth = Bluetooth()
        
        for try await discovered in bluetooth.discoverPeripherals() {
            guard discovered.peripheral.name == "Target name" else { return }
            
            bluetooth.stopDiscovering()
            try await bluetooth.connect(to: discovered.peripheral)
        
            // Do something with the connected peripheral
        }
    }
    
    func example_discoverUsingSingleValueMethodsAndConnect() async throws {
        
        let bluetooth = Bluetooth()
        
        let discovered = try await bluetooth
            .discoverPeripherals(withServiceIds: [CBUUID(string: "AAA")])
            .first{ $0.peripheral.name == "Target name" }
        
        guard let peripheral = discovered?.peripheral else { return }
            
        try await peripheral.connect() // synonym of `bluetooth.connect(to: peripheral)`
        
        // Do something with the connected peripheral
    }
}
