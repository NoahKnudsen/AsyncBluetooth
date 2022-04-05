# AsyncBluetooth

Core Bluetooth + Structured Concurrency

### Basic Usages (more to come): 

#### Using a `for await-in loop` to inspect each bluetooth peripheral discovered:
```swift

let bluetooth = Bluetooth()

for try await discovered in bluetooth.discoverPeripherals() {
  guard discovered.peripheral.name == "Target Name" else { continue }

  bluetooth.stopDiscovering()

  try await discovered.peripheral.connect()
  ...
}

```

#### Using an AsyncSequence single value method to eliminate for loops
```swift

let bluetooth = Bluetooth()
        
let discovered = try await bluetooth
  .discoverPeripherals(withServiceIds: [CBUUID(string: "AAA")])
  .first{ $0.advertisementData["kCBAdvDataManufacturerData"] ... }

guard let peripheral = discovered?.peripheral else { return }
        
try await peripheral.connect()

```
