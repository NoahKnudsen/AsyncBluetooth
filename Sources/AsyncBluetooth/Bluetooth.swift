//
//  Created by Noah Knudsen on 04/04/2022.
//

@_exported import CoreBluetooth
import Combine

public class Bluetooth {
        
    private var manager: Lazy<Manager_P>
    private var delegate: Delegate
    private var bag: Set<AnyCancellable> = []

    public var isScanning: Bool { manager.isScanning ?? false }
   
    public init() {
        let delegate = Delegate()
        self.delegate = delegate
        self.manager = .notInitialised{ CBCentralManager(delegate: delegate, queue: nil) }
        delegate.manager = self
    }
    
    public init(_ mock: Mock) {
        let delegate = Delegate()
        self.delegate = delegate
        self.manager = .notInitialised{
            mock.start(delegate)
            return mock
        }
    }
}


// MARK: Permissions

extension Bluetooth {
    
    public var permission: CBManagerAuthorization { manager.authorisation ?? .denied }
    
    @discardableResult
    public func promptForPermission() async -> CBManagerAuthorization {
        if manager.isInitialised {
            return permission
        } else {
            var cancellable: AnyCancellable?
            
            return await withCheckedContinuation{ continuation in
                cancellable = delegate.didUpdateAuthorization.sink { value in
                    cancellable?.cancel()
                    continuation.resume(returning: value)
                }
                manager.initialise()
            }
        }
    }
    
    private func assertPermissions() async throws -> Manager_P {
        let permission = await promptForPermission()
        switch permission {
        case .allowedAlways:
                return try manager.wrapped.unwrapOrThrow(BluetoothError.unknown)
            
        default:
            throw BluetoothError.permissionNotGranted(permission)
        }
    }
    
    private func permissionGatedStream<T>(
        _ build: @escaping (AsyncThrowingStream<T, Error>.Continuation, Manager_P) async throws -> Void
    ) -> AsyncThrowingStream<T, Error>
    {
        AsyncThrowingStream<T, Error> { continuation in
            Task {
                do {
                    let manager = try await assertPermissions()
                    try await build(continuation, manager)
                }
                catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}


// MARK: Discovering Peripherals

extension Bluetooth {
    
    public func discoverPeripherals(withServiceIds serviceIds: [CBUUID]? = nil)
    -> AsyncThrowingStream<DiscoveredPeripheral, Error>
    {
        permissionGatedStream { [weak self] continuation, manager in
            guard let self = self else {
                throw BluetoothError.deallocation
            }
            guard manager.state == .poweredOn else {
                throw BluetoothError.notPoweredOn
            }
    
            self.delegate.discoveryContinutations.append(continuation)
            
            manager.scanForPeripherals(withServices: serviceIds, options: nil)
        }
    }
    
    public func stopDiscovering() {
        manager.wrapped?.stopScan()
        delegate.stopDiscoveryScan()
    }
}


// MARK: Peripheral Connections

extension Bluetooth {
    
    public func connect(to peripheral: Peripheral) async throws {
        try await connect(to: peripheral, build: {})
    }
    
    func connect(to peripheral: Peripheral, build: @escaping () -> ()) async throws {
        guard peripheral.state != .connected else { return }
        
        let manager = try await assertPermissions()
        
        let updates = try delegate.connectionUpdates {
            build()
            try manager.connect(to: peripheral, options: nil)
        }
        
        for await update in updates.filter({ $0.peripheral == peripheral }) {

            if peripheral.state == .connected {
                return
            } else {
                throw BluetoothError.failedToConnect(peripheral,
                    update.error ?? BluetoothError.unknown
                )
            }
        }
    }
}
