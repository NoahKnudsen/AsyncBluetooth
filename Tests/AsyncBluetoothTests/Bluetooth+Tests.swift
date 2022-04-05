import XCTest
@testable import AsyncBluetooth
import CoreBluetooth

extension BluetoothPublishersTests {
        
    func test_promptForPermission() async {
        
        mock.authorisation = .notDetermined
        
        let task = Task { () -> CBManagerAuthorization in
            await bluetooth.promptForPermission()
        }
        
        mock.authorisation = .allowedAlways
        let permission = await task.value
        
        XCTAssertEqual(permission, .allowedAlways)
        XCTAssertEqual(bluetooth.permission, .allowedAlways)
    }
}

extension BluetoothPublishersTests {
        
    func test_discover_stream_and_stop() async throws {
        let expected = [
            Peripheral.Mock(name: "AAA"),
            Peripheral.Mock(name: "BBB"),
        ]
        var actual: [Peripheral] = []
        
        mock.peripherals = expected.map {
            DiscoveredPeripheral.Mock(
                peripheral: $0,
                advertisementData: [:],
                rssi: 1
            )
        }
        
        for try await discovered in bluetooth.discoverPeripherals() {
            XCTAssertTrue(discovered.peripheral == expected[actual.count])
            actual.append(discovered.peripheral)
            if expected.count == actual.count {
                bluetooth.stopDiscovering()
            }
        }
        
        XCTAssertEqual(expected.count, actual.count)
    }
    
    func test_discover_stream_and_break() async throws {
        mock.peripherals = [
            Peripheral.Mock(name: "AAA"),
            Peripheral.Mock(name: "BBB"),
            Peripheral.Mock(name: "CCC"),
        ].map {
            DiscoveredPeripheral.Mock(
                peripheral: $0,
                advertisementData: [:],
                rssi: 1
            )
        }
        
        var actual: [Peripheral] = []
        
        for try await discovered in bluetooth.discoverPeripherals() {
            actual.append(discovered.peripheral)
            if actual.count == 2 {
                break
            }
        }
        
        XCTAssertTrue(actual.count == 2)
    }
}

extension BluetoothPublishersTests {
    
    func test_connect() async throws {
        let targetPeripheral = Peripheral.Mock(name: "AAA")
        
        let started = expectation(description: "Started waiting for connection to target")
        let completed = expectation(description: "Target peripheral updated")
        
        Task {
            try await bluetooth.connect(to: Peripheral(targetPeripheral, bluetooth)) {
                started.fulfill()
            }
            completed.fulfill()
        }

        
        wait(for: [started], timeout: 1)

        Task {
            // Send additional peripheral connection updates to ensure filtering works
            let redHerringPeripherals = [
                Peripheral.Mock(name:"1"),
                Peripheral.Mock(name:"2")
            ]
            for redHerring in redHerringPeripherals {
                mock.update(redHerring, to: .disconnecting)
            }
            
            // Finally send the connection update for our target
            mock.update(targetPeripheral, to: .connected)
        }
        
        wait(for: [completed], timeout: 2)
        XCTAssertEqual(targetPeripheral.state, .connected)
        
    }
}

final class BluetoothPublishersTests: XCTestCase {
    
    var mock: Bluetooth.Mock!
    var bluetooth: Bluetooth!

    override func setUp() {
        mock = .init()
        bluetooth = .init(mock)
    }
}
