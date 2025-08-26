//
//  BlE.swift
//  CaffeineBuddy
//
//  Created by Maxim Golovlev on 26.08.2025.
//

// Models/BLEDevice.swift
import Foundation
import CoreBluetooth

struct BLEDevice: Identifiable {
    let id: UUID
    let name: String
    let peripheral: CBPeripheral
    let rssi: Int
    
    init(peripheral: CBPeripheral, rssi: Int) {
        self.id = peripheral.identifier
        self.name = peripheral.name ?? "Unknown Device"
        self.peripheral = peripheral
        self.rssi = rssi
    }
}

struct BLECharacteristic {
    let uuid: CBUUID
    let properties: CBCharacteristicProperties
    let value: Data?
}

struct ReceivedData: Identifiable {
    let id = UUID()
    let timestamp: Date
    let characteristicUUID: String
    let data: Data
    let value: String
}

// Services/BLEService.swift
import Foundation
import CoreBluetooth
import Combine

class BLEService: NSObject, ObservableObject {
    static let shared = BLEService()
    
    private var centralManager: CBCentralManager!
    
    @Published var discoveredDevices: [BLEDevice] = []
    @Published var connectedDevice: CBPeripheral?
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var receivedData: [ReceivedData] = []
    @Published var services: [CBService] = []
    @Published var characteristics: [CBCharacteristic] = []
    
    private var dataSubject = PassthroughSubject<ReceivedData, Never>()
    var dataPublisher: AnyPublisher<ReceivedData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        
        discoveredDevices.removeAll()
        isScanning = true
        
        // Сканируем устройства с сервисами (можно указать конкретные сервисы)
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect(to device: BLEDevice) {
        centralManager.stopScan()
        centralManager.connect(device.peripheral, options: nil)
    }
    
    func disconnect() {
        guard let peripheral = connectedDevice else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func writeData(to characteristic: CBCharacteristic, data: Data) {
        guard let peripheral = connectedDevice else { return }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func readValue(from characteristic: CBCharacteristic) {
        guard let peripheral = connectedDevice else { return }
        peripheral.readValue(for: characteristic)
    }
    
    func subscribeToCharacteristic(_ characteristic: CBCharacteristic) {
        guard let peripheral = connectedDevice else { return }
        peripheral.setNotifyValue(true, for: characteristic)
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
        case .poweredOff:
            print("Bluetooth is powered off")
            isConnected = false
            isScanning = false
        case .unsupported:
            print("Bluetooth is not supported")
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = BLEDevice(peripheral: peripheral, rssi: RSSI.intValue)
        
        if !discoveredDevices.contains(where: { $0.id == device.id }) {
            discoveredDevices.append(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = peripheral
        isConnected = true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedDevice = nil
        isConnected = false
        services.removeAll()
        characteristics.removeAll()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
    }
}

// MARK: - CBPeripheralDelegate
extension BLEService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        self.services = services
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        self.characteristics.append(contentsOf: characteristics)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        
        let receivedData = ReceivedData(
            timestamp: Date(),
            characteristicUUID: characteristic.uuid.uuidString,
            data: data,
            value: data.hexString
        )
        
        self.receivedData.append(receivedData)
        dataSubject.send(receivedData)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Write error: \(error.localizedDescription)")
        } else {
            print("Data written successfully")
        }
    }
}

// Расширение для преобразования Data в hex string
extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}


// ViewModels/BLEViewModel.swift
import Foundation
import Combine
import CoreBluetooth

class BLEViewModel: ObservableObject {
    private let bleService = BLEService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var discoveredDevices: [BLEDevice] = []
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var receivedData: [ReceivedData] = []
    @Published var services: [CBService] = []
    @Published var characteristics: [CBCharacteristic] = []
    @Published var connectedDeviceName: String = ""
    @Published var errorMessage: String = ""
    
    @Published var textToSend: String = ""
    @Published var selectedCharacteristic: CBCharacteristic?
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        bleService.$discoveredDevices
            .assign(to: &$discoveredDevices)
        
        bleService.$isScanning
            .assign(to: &$isScanning)
        
        bleService.$isConnected
            .assign(to: &$isConnected)
        
        bleService.$receivedData
            .assign(to: &$receivedData)
        
        bleService.$services
            .assign(to: &$services)
        
        bleService.$characteristics
            .assign(to: &$characteristics)
        
        bleService.$connectedDevice
            .map { $0?.name ?? "Not Connected" }
            .assign(to: &$connectedDeviceName)
        
        bleService.dataPublisher
            .sink { [weak self] data in
                self?.receivedData.append(data)
            }
            .store(in: &cancellables)
    }
    
    func startScanning() {
        bleService.startScanning()
    }
    
    func stopScanning() {
        bleService.stopScanning()
    }
    
    func connect(to device: BLEDevice) {
        bleService.connect(to: device)
    }
    
    func disconnect() {
        bleService.disconnect()
    }
    
    func sendText() {
        guard let characteristic = selectedCharacteristic,
              let data = textToSend.data(using: .utf8) else {
            errorMessage = "Select characteristic or enter text"
            return
        }
        
        bleService.writeData(to: characteristic, data: data)
        textToSend = ""
    }
    
    func sendData(_ data: Data) {
        guard let characteristic = selectedCharacteristic else {
            errorMessage = "Select characteristic first"
            return
        }
        
        bleService.writeData(to: characteristic, data: data)
    }
    
    func readCharacteristic(_ characteristic: CBCharacteristic) {
        bleService.readValue(from: characteristic)
    }
    
    func subscribeToCharacteristic(_ characteristic: CBCharacteristic) {
        bleService.subscribeToCharacteristic(characteristic)
    }
    
    func clearReceivedData() {
        receivedData.removeAll()
    }
}

// Views/DeviceListView.swift
import SwiftUI

struct DeviceListView: View {
    @StateObject private var viewModel = BLEViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                connectionStatusView
                
                if viewModel.isConnected {
                    connectedDeviceView
                } else {
                    deviceList
                }
                
                Spacer()
            }
            .navigationTitle("BLE Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    scanButton
                }
            }
        }
    }
    
    private var connectionStatusView: some View {
        HStack {
            Circle()
                .fill(viewModel.isConnected ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            Text(viewModel.connectedDeviceName)
                .font(.subheadline)
        }
        .padding()
    }
    
    private var scanButton: some View {
        Button(action: {
            if viewModel.isScanning {
                viewModel.stopScanning()
            } else {
                viewModel.startScanning()
            }
        }) {
            Image(systemName: viewModel.isScanning ? "stop.circle" : "arrow.clockwise")
            Text(viewModel.isScanning ? "Stop" : "Scan")
        }
    }
    
    private var deviceList: some View {
        List(viewModel.discoveredDevices) { device in
            Button(action: {
                viewModel.connect(to: device)
            }) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(device.name)
                            .font(.headline)
                        Text("RSSI: \(device.rssi)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(device.id.uuidString.prefix(8))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var connectedDeviceView: some View {
        VStack {
            NavigationLink("Services & Characteristics") {
                ServicesView(viewModel: viewModel)
            }
            .padding()
            
            NavigationLink("Data Communication") {
                DataCommunicationView(viewModel: viewModel)
            }
            .padding()
            
            Button("Disconnect") {
                viewModel.disconnect()
            }
            .foregroundColor(.red)
            .padding()
        }
    }
}

// Views/ServicesView.swift
struct ServicesView: View {
    @ObservedObject var viewModel: BLEViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.services, id: \.uuid) { service in
                Section(header: Text("Service: \(service.uuid.uuidString)")) {
                    ForEach(viewModel.characteristics.filter { $0.service?.uuid == service.uuid }, id: \.uuid) { characteristic in
                        CharacteristicRow(characteristic: characteristic, viewModel: viewModel)
                    }
                }
            }
        }
        .navigationTitle("Services")
    }
}

struct CharacteristicRow: View {
    let characteristic: CBCharacteristic
    @ObservedObject var viewModel: BLEViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(characteristic.uuid.uuidString)
                .font(.headline)
            
            Text("Properties: \(characteristic.properties.stringDescription)")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Button("Read") {
                    viewModel.readCharacteristic(characteristic)
                }
                .buttonStyle(.bordered)
                
                if characteristic.properties.contains(.notify) {
                    Button("Subscribe") {
                        viewModel.subscribeToCharacteristic(characteristic)
                    }
                    .buttonStyle(.bordered)
                }
                
                if characteristic.properties.contains(.write) {
                    Button("Select") {
                        viewModel.selectedCharacteristic = characteristic
                    }
                    .buttonStyle(.bordered)
                    .background(viewModel.selectedCharacteristic?.uuid == characteristic.uuid ? Color.blue : Color.clear)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// Views/DataCommunicationView.swift
struct DataCommunicationView: View {
    @ObservedObject var viewModel: BLEViewModel
    
    var body: some View {
        VStack {
            sendDataSection
            
            receivedDataSection
            
            Spacer()
        }
        .navigationTitle("Data Communication")
    }
    
    private var sendDataSection: some View {
        VStack(alignment: .leading) {
            Text("Send Data")
                .font(.headline)
            
            TextField("Enter text to send", text: $viewModel.textToSend)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 4)
            
            HStack {
                Button("Send Text") {
                    viewModel.sendText()
                }
                .disabled(viewModel.selectedCharacteristic == nil)
                
                Button("Send Test Data") {
                    let testData = Data([0x01, 0x02, 0x03, 0x04])
                    viewModel.sendData(testData)
                }
                .disabled(viewModel.selectedCharacteristic == nil)
            }
            
            if let characteristic = viewModel.selectedCharacteristic {
                Text("Selected: \(characteristic.uuid.uuidString)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
    
    private var receivedDataSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Received Data")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear") {
                    viewModel.clearReceivedData()
                }
                .foregroundColor(.red)
            }
            
            List(viewModel.receivedData.reversed()) { data in
                VStack(alignment: .leading) {
                    Text(data.value)
                        .font(.body)
                    Text("Char: \(data.characteristicUUID)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(data.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
    }
}

// Расширение для преобразования CBCharacteristicProperties в строку
extension CBCharacteristicProperties {
    var stringDescription: String {
        var descriptions: [String] = []
        
        if contains(.broadcast) {
            descriptions.append("Broadcast")
        }
        if contains(.read) {
            descriptions.append("Read")
        }
        if contains(.writeWithoutResponse) {
            descriptions.append("WriteWithoutResponse")
        }
        if contains(.write) {
            descriptions.append("Write")
        }
        if contains(.notify) {
            descriptions.append("Notify")
        }
        if contains(.indicate) {
            descriptions.append("Indicate")
        }
        if contains(.authenticatedSignedWrites) {
            descriptions.append("AuthenticatedSignedWrites")
        }
        if contains(.extendedProperties) {
            descriptions.append("ExtendedProperties")
        }
        if contains(.notifyEncryptionRequired) {
            descriptions.append("NotifyEncryptionRequired")
        }
        if contains(.indicateEncryptionRequired) {
            descriptions.append("IndicateEncryptionRequired")
        }
        
        return descriptions.joined(separator: ", ")
    }
}
