//
//  ScopeBTCentral.swift
//  Aeroscope Proto
//
//  Created by Jonathan Ward on 8/14/15.
//  Copyright (c) 2015 Jonathan Ward. All rights reserved.
//

import Foundation
import CoreBluetooth

//protocol FpgaUpdateDelegate : class {
//    func didConnect()
//    //func didDisconnect()
//    func didReceive(packet: [UInt8])
//}
//
//protocol ScopeFrameDelegate : class {
//    func didConnect()
//    func didDisconnect()
//    func didReceive(packet: [UInt8])
//}
//
//protocol ScopeTelemetryDelegate : class {
//    func didConnect()
//    func didDisconnect()
//    func didReceive(packet: [UInt8])
//}
//
//protocol ScopeCommsDelegate : class {
//    func didConnect()
//    func didDisconnect()
//    func didReceive(packet: [UInt8])
//}

protocol ConnectionDelegate : class {
    func didConnect()
    func didReconnect()
    func didDisconnect()
}

enum PacketType {
    case data
    case comms
    case fpga
}

protocol PacketDelegate : class {
    func didReceive(packet: [UInt8], type: PacketType)
}

protocol ScanningDelegate : class {
    func startScanning()
    func stopScanning()
}





class ScopeDevice : Equatable
{
    let bt : CBPeripheral
    var advertisementData: [String : Any]
    var rssi : Double
    
    private var _advertisedName : String?
    
    var advertisedName : String {
        //return original advertised name, or name that gets overwritten
        get {
            return _advertisedName ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "UNKNOWN"
        }
        
        set {
            _advertisedName = newValue
        }
    }
    
    init(with peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        self.bt = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi.doubleValue
    }
    
    static func == (lhs: ScopeDevice, rhs: ScopeDevice) -> Bool {
        return lhs.bt == rhs.bt 
    }
}



class ScopeComms: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    struct notifications {
        static let peripheral = Notification.Name("com.Aeroscope.discoveredPeripheral")
        static let scan = Notification.Name("com.Aeroscope.scanStatusChanged")
    }
    
    var centralManager : CBCentralManager!
    var peripheral : ScopeDevice?
    let BLEServiceUUID = CBUUID(string: "F9541234-91B3-BD9A-F077-80F2A6E57D00")
    let DataCharUUID = CBUUID(string: "1235")
    let CommsInCharUUID = CBUUID(string: "1236")
    let StateCharUUID = CBUUID(string: "1237")
    let CommsOutCharUUID = CBUUID(string: "1239")
    
    let fpgaUpdateServiceUUID = CBUUID(string: "BC2CD51A-B40D-424B-95C9-987769642F81")
    let fpgaInCharUUID = CBUUID(string: "BC2C0001-B40D-424B-95C9-987769642F81")
    let fpgaOutCharUUID = CBUUID(string: "BC2C0002-B40D-424B-95C9-987769642F81")
    
    let firmUpdateServiceUUID = CBUUID(string: "BC2CD51A-B40D-424B-95C9-987769642F81")
   
    
    var devices : [ScopeDevice] = []
    
    var commsInChar : CBCharacteristic?
    let commsInCharLength = 20
    var dataChar : CBCharacteristic?
    let dataCharLength = 20
    var stateChar : CBCharacteristic?
    let stateCharLength = 20
    var commsOutChar : CBCharacteristic?
    let commsOutCharLength = 20
    
    var fpgaInChar : CBCharacteristic?
    var fpgaOutChar : CBCharacteristic?
    
//    weak var fpgaUpdateDelegate : FpgaUpdateDelegate?
//    weak var scopeFrameDelegate : ScopeFrameDelegate?
//    weak var telemetryDelegate : ScopeTelemetryDelegate?
//    weak var scopeCommsDelegate : ScopeCommsDelegate?
//    weak var scopeConnectionDelegate : ScopeConnectionDelegate?
    
    weak var connectionDelegate : ConnectionDelegate?
    weak var scanningDelegate : ScanningDelegate?
    weak var packetDelegate : PacketDelegate?
    
    //var connected = false
    
    var isReconnected = false
    
    
    override init() {
        super.init()
        setDelegate()
    }
    
    func setDelegate() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey : true])
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: [BLEServiceUUID], options: nil)
        print("Starting to Scan")
        NotificationCenter.default.post(name: notifications.scan, object: self)
        scanningDelegate?.startScanning()
    }
    
    func stopScanning() {
        centralManager.stopScan()
        scanningDelegate?.stopScanning()
    }
    
    func isScanning() -> Bool {
        return centralManager.isScanning
    }
    
    func isPoweredOn() -> Bool {
        return centralManager.state == .poweredOn
    }
    
    func disconnect() {
        guard let peripheral = peripheral else {
            return
        }
        guard let services = peripheral.bt.services else {
//            centralManager.cancelPeripheralConnection(peripheral.bt)
            return
        }
        for service in services {
            guard let characteristics = service.characteristics else {
                centralManager.cancelPeripheralConnection(peripheral.bt)
                return
            }
            for characteristic in characteristics {
                peripheral.bt.setNotifyValue(false, for: characteristic)
            }
            
        }
        centralManager.cancelPeripheralConnection(peripheral.bt)
    }
    
    func reconnect() {
        if !isPoweredOn() {
            self.setDelegate()
        }
        if let peripheral = peripheral {
            let connectedPeriphs = centralManager.retrieveConnectedPeripherals(withServices: [BLEServiceUUID])
            if connectedPeriphs.contains(peripheral.bt) {
                centralManager.connect(peripheral.bt, options: nil )
                isReconnected = true
            }
            else {
                isReconnected = false
                startScanning()
            }
        }

    }
    
    
    func sendCpu(_ packet: [UInt8]) {
        assert(packet.count == commsInCharLength, "Ctrl Packet Error \(#file) \(#line)")
        let ctrl_data = Data(bytes: UnsafePointer<UInt8>(packet), count: packet.count)
        print("CPU Packet: \(packet)")
        if let scope = peripheral, let char = commsInChar {
            scope.bt.writeValue(ctrl_data, for: char, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func sendFpga1(_ packet: [UInt8]) {
        let fpga1_data = Data(bytes: UnsafePointer<UInt8>(packet), count: packet.count)
        print("FPGA Packet: \(packet)")
        if let scope = peripheral, let char = stateChar {
            scope.bt.writeValue(fpga1_data, for: char, type: CBCharacteristicWriteType.withResponse)
        }
        
    }
    
    func sendFpgaUpdate(_ packet: [UInt8]) {
        //let fpgaUpdateData = Data(bytes: UnsafePointer<UInt8>(packet), count: packet.count)
        print("FPGAUPDATE SENT: \(packet)")
        let fpgaUpdateData = Data(bytes: packet)
        if let scope = peripheral, let char = fpgaInChar {
            scope.bt.writeValue(fpgaUpdateData, for: char, type: CBCharacteristicWriteType.withoutResponse)
        }
        
        
//        peripheral?.writeValue(fpgaUpdateData, for: fpgaInChar!, type: CBCharacteristicWriteType.withResponse)
        
    }
    
//    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//
//        if characteristic.uuid == fpgaInCharUUID {
//            print("fpga update packet written")
//        }
//
//    }
//    
//    
    
    
    //-------CBCentralManagerDelegate Functions---------//
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOff:
            print("CoreBluetooth BLE hardware is powered off")
            
        case .poweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            print("Starting to Scan...")
            startScanning()
            
        case .resetting:
            print("CoreBluetooth BLE hardware is resetting")
            
        case .unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
            
        case .unknown:
            print("CoreBluetooth BLE state is unknown");
            
        case .unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform");
            
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                                              advertisementData: [String : Any],
                                              rssi RSSI: NSNumber)
    {
        print("Discovered \(peripheral.name ?? "nil") at RSSI: \(RSSI)")
        print(peripheral.description)
        print("Advertised Name: \(advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "nil")")
        //print("Other Name: \(advertisementData[CBUUIDDeviceNameString])")
        let newPeripheral = ScopeDevice(with: peripheral, advertisementData: advertisementData, rssi: RSSI)
        
        if devices.contains(newPeripheral) == false {
            devices.append(ScopeDevice(with: peripheral, advertisementData: advertisementData, rssi: RSSI))
            NotificationCenter.default.post(name: ScopeComms.notifications.peripheral, object: self)
        }
        
//        if devices.contains(newPeripheral) == false {
//            devices.append(newPeripheral)
//            NotificationCenter.default.post(name: ScopeComms.notifications.peripheral, object: self)
//        }
        
        let prefs = UserDefaults.standard
        if let myNSUUID = prefs.value(forKey: "My Aeroscope") {
            if myNSUUID as? String == peripheral.identifier.uuidString {
                self.peripheral = newPeripheral
                centralManager.connect(peripheral, options: nil)
            }
        }
        
    }
    
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        
        //TODO: Clean this up
        //we check peripheral but dont do anything if it isnt true
        if (peripheral == self.peripheral?.bt) {
            
            //self.connected = true
            print("connected to: \(self.peripheral?.advertisedName ?? "nil")")
            
            if (peripheral.services != nil) {
                print("services already exist")
            }
            else
            {
                peripheral.discoverServices([BLEServiceUUID, fpgaUpdateServiceUUID])
            }
        }
        
        let prefs = UserDefaults.standard
        prefs.set(peripheral.identifier.uuidString, forKey: "My Aeroscope")
        
        
        //central.stopScan()
        stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                                                   error: Error?) {
        //Try to Connect again
        print("FAIL TO CONNECT")
        central.cancelPeripheralConnection(peripheral)
        central.connect(peripheral, options:nil)
        
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                                                error: Error?) {
        print("*****DISCONNECTED******")

        devices = []
        dataChar = nil
        commsInChar = nil
        stateChar = nil
        commsOutChar = nil

        connectionDelegate?.didDisconnect()
    }
    
    //---------CBPeripheralDelegate Functions-----------//
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error:Error?) {
        print("discovered services")
        
        let uuidsForBTService: [CBUUID] = [DataCharUUID, CommsInCharUUID, StateCharUUID, CommsOutCharUUID]
        
        let uuidsForFpgaUpdateServce: [CBUUID] = [fpgaInCharUUID, fpgaOutCharUUID]
        
        if (peripheral != self.peripheral?.bt) {
            // Wrong Peripheral
            print("wrong peripheral")
            return
        }
        
        if (error != nil) {
            print("an error occured: \(error!)")
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            // No Services
            print("No Services")
            return
        }
        
        
        
        for service in peripheral.services! {
            if service.uuid == BLEServiceUUID {
                print("found scope service: \(service.uuid)")
                //peripheral.discoverCharacteristics(uuidsForBTService, forService: service as CBService)
                peripheral.discoverCharacteristics(uuidsForBTService, for: service)
            }
            else if service.uuid == fpgaUpdateServiceUUID {
                print("found Fpga Update Service: \(service.uuid)")
                peripheral.discoverCharacteristics(uuidsForFpgaUpdateServce, for: service)
            }
            else {
                print("didn't find our servce: \(service.uuid)")
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service:CBService, error:Error?) {
        print("discovered some characteristics for service \(service.characteristics!)")
        
        if (service.characteristics!.count == 0) {
            print("no characteristics")
        }
        
        if service.uuid == BLEServiceUUID {
            for characteristic in service.characteristics! {
                if characteristic.uuid == DataCharUUID {
                    print("discovered data Characteristic")
                    dataChar = characteristic
                    peripheral.setNotifyValue(true, for:characteristic)
                    print("set notification for Data Char")
                }
                    
                else if characteristic.uuid == CommsInCharUUID {
                    print("discovered Comms In Characterisitc")
                    commsInChar = characteristic
                    //scope.updateSettings()
                }
                    
                else if characteristic.uuid == StateCharUUID {
                    print("discovered State Characteristic")
                    stateChar = characteristic
                }
                    
                    
                else if characteristic.uuid == CommsOutCharUUID {
                    print("discovered Comms Out Characteristc")
                    commsOutChar = characteristic
                    peripheral.setNotifyValue(true, for:characteristic)
                    print("set notification for Comms Out Char")
                    
                }
                    
                else {
                    print("discovered unknown characteristic or maybe none")
                }
                
                if (dataChar != nil && commsInChar != nil && stateChar != nil && commsOutChar != nil) {
                    connectionDelegate?.didConnect()

                    if isReconnected {
                        connectionDelegate?.didReconnect()
                        isReconnected = false
                    }
                }
            }
        }
            
        else if service.uuid == fpgaUpdateServiceUUID {
            for characteristic in service.characteristics! {
                if characteristic.uuid == fpgaInCharUUID {
                    print ("discovered Fpga Update In Characterisitc")
                    fpgaInChar = characteristic
                }
                    
                else if characteristic.uuid == fpgaOutCharUUID {
                    print ("discovered Fpga Update Out Characteristic")
                    fpgaOutChar = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                }
                    
                else {
                    print("discovered uknown characteristic: \(characteristic.uuid)")
                }
                
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                                                    error: Error?) {
        
        if (characteristic.uuid == DataCharUUID) {
            var decoded = [UInt8](repeating: 0, count: 20)
            let length = characteristic.value!.count
            (characteristic.value! as NSData).getBytes(&decoded, length: length)
            packetDelegate?.didReceive(packet: decoded, type: .data)
        }
        
        if (characteristic.uuid == CommsOutCharUUID) {
            var decoded = [UInt8](repeating: 0, count: 20)
            let length = characteristic.value!.count
            (characteristic.value! as NSData).getBytes(&decoded, length: length)
            packetDelegate?.didReceive(packet: decoded, type: .comms)
        }
            
        else if (characteristic.uuid == fpgaOutCharUUID) {
            var decoded = [UInt8](repeating: 0, count: 20)
            let length = characteristic.value!.count
            (characteristic.value! as NSData).getBytes(&decoded, length: length)
            
            packetDelegate?.didReceive(packet: decoded, type: .fpga)
            
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateNotificationStateFor characteristic: CBCharacteristic,
                                                                error: Error?) {
        
        if (error == nil) {
            print("notification set for \(characteristic)")
           

        }
            
        else {
            print("problems setting notification")
        }
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("**************NAME CHANGE*****************")
    }
    
    //    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    
    
}

