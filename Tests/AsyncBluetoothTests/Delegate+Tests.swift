import XCTest
@testable import AsyncBluetooth
import CoreBluetooth

final class DelegateTests: XCTestCase {
    
    var delegate: Bluetooth.Delegate!
    
    override func setUp() {
        delegate = Bluetooth.Delegate()
    }
    
    func test_discover_and_stop() async {
        
        let expected = [
            Peripheral.Mock(name: "1"),
            Peripheral.Mock(name: "2"),
            Peripheral.Mock(name: "3"),
        ]
        let unexpected = [
            Peripheral.Mock(name: "4"),
            Peripheral.Mock(name: "5"),
        ]
        var actual: [Peripheral] = []
        
        
        // Helper to send the next peripheral to be discovered to the delegate
        let discoverNext: () -> Void = {
            var peripherals = expected + unexpected
           
            return {
                guard let peripheral = peripherals.first else { return }
                peripherals = Array(peripherals.dropFirst())
                Task {
                    self.delegate.didDiscover(
                        peripheral: peripheral,
                        advertisementData: [:],
                        rssi: 1
                    )
                }
            }
        }()

        let stream = delegate.discoveries{ discoverNext() }
        
        for await discovered in stream {
            
            XCTAssertTrue(discovered.peripheral == expected[actual.count])
            actual.append(discovered.peripheral)
            
            if actual.count == expected.count {
                delegate.stopDiscoveryScan()
            }
            
            discoverNext()
        }
        
        XCTAssertEqual(actual.count, expected.count)
    }
  
    func test_connections_stream() async {
        
        let peripherals = [
            Peripheral.Mock(name: "A"),
            Peripheral.Mock(name: "B"),
            Peripheral.Mock(name: "C"),
        ]
        var actual: [Peripheral] = []
        
        let updateNext: () -> Void = {
            var peripherals = peripherals
            return {
                guard let peripheral = peripherals.first else { return }
                peripherals = Array(peripherals.dropFirst())
                Task {
                    self.delegate.didUpdateConnection(to: peripheral, error: nil)
                }
            }
        }()
        
        let updates = delegate.connectionUpdates{ updateNext() }
        
        for await update in updates {
            
            XCTAssertTrue(update.peripheral == peripherals[actual.count])
            actual.append(update.peripheral)
            
            if actual.count == peripherals.count {
                break
            } else {
                updateNext()
            }
        }
    }
}
