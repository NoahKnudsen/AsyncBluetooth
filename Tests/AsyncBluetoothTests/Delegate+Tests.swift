import XCTest
@testable import AsyncBluetooth
import CoreBluetooth

final class DelegateTests: XCTestCase {
    
    var delegate: Bluetooth.Delegate!
    
    override func setUp() {
        delegate = Bluetooth.Delegate()
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
