# AsyncBluetooth

Core Bluetooth + Structured Concurrency

Usages: 
```swift

let bluetooth = Bluetooth()

for try await discovered in bluetooth.discoverPeripherals() {
  guard discovered.peripheral.name == "Target Name" else { continue }
}

```
