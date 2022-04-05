//
//  Created by Noah Knudsen on 04/04/2022.
//

import CoreBluetooth
import Combine

public protocol Peripheral_P: AnyObject {
    
    var identifier: UUID { get }
    var name: String? { get }
    var state: CBPeripheralState { get }
}

extension CBPeripheral: Peripheral_P {}
extension CBPeripheralState: Equatable {}
