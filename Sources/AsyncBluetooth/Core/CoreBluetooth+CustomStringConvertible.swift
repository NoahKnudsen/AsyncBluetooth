//
//  Created by Noah Knudsen on 04/04/2022.
//

import CoreBluetooth

extension CBManagerAuthorization: CustomStringConvertible {

    public var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .allowedAlways: return "Allowed Always"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        @unknown default: return "Unknown"
        }
    }
}

extension CBManagerState: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .unknown:      return "Unknown"
        case .resetting:    return "Resetting"
        case .unsupported:  return "Unsupported"
        case .unauthorized: return "Unauthorized"
        case .poweredOff:   return "Powered off"
        case .poweredOn:    return "Powered on"
        @unknown default:   return "Unknown"
        }
    }
}

extension CBPeripheralState: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .disconnected:  return "Disconnected"
        case .connecting:    return "Connecting"
        case .connected:     return "Connected"
        case .disconnecting: return "Disconnecting"
        @unknown default:    return "Unknown"
        }
    }
}
