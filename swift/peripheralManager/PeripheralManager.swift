////  PowerMeterManager.swift
//  WattDr

//
//  Created by Peter Lin on 7/7/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import CoreBluetooth
import Realm
import RealmSwift

@objc public protocol PeripheralDelegate {
    func updatedValue(_ data:PeripheralData);
    @objc optional func didDiscover(_ peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber);
    @objc optional func peripheralConnected(_ peripheral:CBPeripheral);
    @objc optional func bluetoothOff(_ message:String);
}

class PeripheralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    static let HRM_HEART_RATE_SERVICE_UUID = "180D";
    static let HRM_DEVICE_INFO_SERVICE_UUID = "180A";
    static let POWER_METER_UUID = "1818";
    static let SPEED_CADENCE_UUID = "1816";
    static let FITNESS_MACHINE = "1826";
    static let POWER_FEATURE = "2A65";
    static let POWER_MEASUREMENT = "2A63";
    static let POWER_CONTROL = "2A66";
    static let BATTERY_UUID = "180F";
    static let BATTERY_LEVEL = "2A19";
    static let BATTERY_LEVEL_STATE = "2A1B";
    static let HEARTRATE_CHARACTERISTIC = "2A37";
    static let SPEED_CHARACTERISTIC = "2A5B";
    static let SPEED_CADENCE_CONTROL = "2A55";
    static let MANUFACTURER_NAME = "2A29";
    static let MODEL_NUMBER = "2A24";
    static let SENSOR_LOCATION = "2A38";
    static let TEMPERATURE_MEASUREMENT = "2A1C";
    let heartRateServiceUUID = CBUUID(string: HRM_HEART_RATE_SERVICE_UUID)
    let deviceInfoServiceUUID = CBUUID(string: HRM_DEVICE_INFO_SERVICE_UUID)
    let powerMeterServiceUUID = CBUUID(string: POWER_METER_UUID)
    let speedCadenceServiceUUID = CBUUID(string: SPEED_CADENCE_UUID)
    let batteryServiceUUID = CBUUID(string: BATTERY_UUID)

    var centralManager:CBCentralManager!;
    // Device Map is the list of devices discovered
    var deviceMap = [String:CBPeripheral]();
    var devTypeMap = [CBPeripheral:DeviceType]();
    // Device List is the current list of connected devices
    var deviceList = [CBPeripheral]();
    // listeners that implement PowerMeterDelegate
    var listeners = [PeripheralDelegate]();
    var bluetoothState:CBManagerState = CBManagerState.poweredOff;
    var readings = [AnyObject]();
    var realm:Realm?
    var savedDevices:PairedDevices?
    var appDelegate:AppDelegate?
    var editingBegin = false;
    var speedSensor:CBPeripheral?
    var cscControlCharacteristic:CBCharacteristic?
    
    // variables for calculating speed
    var previousRevolutionCount:UInt32 = 0;
    var previousSpeedMetersPerSec = 0.0;
    var currentSpeedMetersPerSec = 0.0;
    var workoutRevolutionCount:Int32 = 0;
    var previousWheelEvent:Double = 0.0;
    var previousCrankRevolutionCount:UInt16 = 0;
    var previousCrankEvent:Double = 0.0;
    // New Gatorskin Hardshell 28mm tire 2160mm
    // Specialized Turbo 24mm tire 2131mm
    var circumference:Int16 = 2160;

    override init() {
        super.init();
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate;
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        self.realm = try! Realm();
    }
    
    func ResetSpeedCounters() {
        previousCrankEvent = 0.0;
        previousWheelEvent = 0.0;
        previousRevolutionCount = 0;
        previousSpeedMetersPerSec = 0;
        previousCrankRevolutionCount = 0;
    }
    
    func getAppDelegate() {
        if self.appDelegate == nil {
            self.appDelegate = UIApplication.shared.delegate as? AppDelegate;
        }
    }
    
    func setTireCircumference(_ mm:Int16) {
        self.circumference = mm;
    }
    
    // resetSpeedSensor will zero the workout revolution count and the speed sensor 
    func resetSpeedSensor() {
        self.workoutRevolutionCount = 0;
        self.resetSpeedCummulative();
    }
    
    func currentDistance(_ circumferenceMM:Int) -> Double {
        return Double(self.workoutRevolutionCount) * ( Double(circumferenceMM) / 1000.0);
    }
    
    func saveDevice(_ peripheral:CBPeripheral, deviceType:DeviceType) {
        if self.savedDevices == nil {
            self.savedDevices = PairedDevices();
            try! realm?.write {
                // realm doesn't have a upsert, so we save the new object immediately
                realm?.add(self.savedDevices!);
            }
        }
        let newdev = Device();
        newdev.name = peripheral.name;
        newdev.uuidString = peripheral.identifier.uuidString;
        newdev.deviceType = String(describing: deviceType);
        var add = true;
        for device in (self.savedDevices?.devices)! {
            if device.uuidString == peripheral.identifier.uuidString {
                add = false;
                break;
            }
        }
        if add {
            try! realm?.write {
                self.savedDevices?.devices.append(newdev);
            }
        }
    }
    
    // Update is called to save the DeviceType
    func updateDevice(_ peripheral:CBPeripheral, deviceTyp:DeviceType) {
        var dev:Device?;
        for device in (self.savedDevices?.devices)! {
            if peripheral.identifier.uuidString == device.uuidString {
                dev = device;
                break;
            }
        }
        try! realm?.write {
            dev?.deviceType = deviceTyp.rawValue;
        }
    }
    
    func addDelegate(_ vcdelegate:PeripheralDelegate) {
        self.listeners.append(vcdelegate);
    }
    
    func removeDelegate(_ pdelegate:PeripheralDelegate) {
        var index = 0;
        for pdel in self.listeners {
            if pdelegate === pdel {
                self.listeners.remove(at: index);
                break;
            }
            index = index + 1;
        }
    }
    
    func deviceCount() -> Int {
        return self.deviceList.count;
    }
    
    func stopScan() {
        centralManager.stopScan();
    }
    
    func scanForHRM() -> Void {
        self.centralManager.scanForPeripherals(withServices: [heartRateServiceUUID, deviceInfoServiceUUID, batteryServiceUUID], options: nil)
    }
    
    func scanForPowerMeter() -> Void {
        self.centralManager.scanForPeripherals(withServices: [powerMeterServiceUUID, deviceInfoServiceUUID, batteryServiceUUID], options: nil)
    }
    
    func scanForSpeedCadence() -> Void {
        self.centralManager.scanForPeripherals(withServices: [speedCadenceServiceUUID, deviceInfoServiceUUID, batteryServiceUUID], options: nil)
    }
    
    func scanForAll() {
        self.centralManager.scanForPeripherals(withServices: [speedCadenceServiceUUID, deviceInfoServiceUUID, batteryServiceUUID, powerMeterServiceUUID, heartRateServiceUUID], options: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            print("poweredOn")
            self.bluetoothState = .poweredOn;
            // check to see if there are any saved devices
            let result = self.realm?.objects(PairedDevices.self);
            if result != nil && (result?.count)! > 0 {
                self.savedDevices = result?.first;
                let services:[CBUUID] = [powerMeterServiceUUID, speedCadenceServiceUUID, deviceInfoServiceUUID, batteryServiceUUID];
                let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: services)
                if lastPeripherals.count > 0 {
                    for peripheral in lastPeripherals {
                        self.centralManager.connect(peripheral, options: nil);
                    }
                } else {
                    self.scanForAll();
                }
            }

        case .poweredOff:
            self.bluetoothState = .poweredOff;
            // notify listeners
            for pmdel in self.listeners {
                if pmdel != nil {
                    pmdel.bluetoothOff!("Please turn of bluetooth. WattDr uses bluetooth to connect to the power meter.");
                }
            }
        case .resetting:
            print("--- central state is resetting")
            // if it resets, we might want to reconnect to the existing devices
        case .unauthorized:
            print("--- central state is unauthorized")
        case .unknown:
            print("--- central state is unknown")
        case .unsupported:
            print("--- central state is unsupported")
        }
    }
    
    func shouldConnect(_ peripheral:CBPeripheral) -> Bool {
        self.getAppDelegate();
        var connect = self.appDelegate?.discoverStatus;
        if self.savedDevices != nil {
            for device in (self.savedDevices?.devices)! {
                if device.uuidString == peripheral.identifier.uuidString {
                    connect = true;
                    break;
                }
            }
        }
        return connect!;
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.getAppDelegate();
        self.deviceMap[peripheral.identifier.uuidString] = peripheral;
        peripheral.delegate = self;
        if (self.appDelegate?.discoverStatus)! {
            for pmdel in self.listeners {
                pmdel.didDiscover!(peripheral, advertisementData: advertisementData, rssi: RSSI);
                if let value = peripheral.name {
                    print("connecting to \(value)")
                }
            }
        } else if shouldConnect(peripheral) {
            self.centralManager.connect(peripheral, options: nil);
        }
    }
    
    // function will look up the peripheral by the string UUID and attempt
    // to connect to CBCentralManager
    func connectPeripheral(_ identifier:String) {
        if let peripheral = self.deviceMap[identifier] {
            self.centralManager.connect(peripheral, options: nil);
        }
    }
    
    // function will delete the peripheral and disconnect
    func deletePeripheral(_ identifier:String) {
        self.editingBegin = true;
        // delete the peripheral and disconnect
        if let peripheral = self.deviceMap[identifier] {
            for device in (self.savedDevices?.devices)! {
                if device.uuidString == identifier {
                    let index = self.savedDevices?.devices.index(of: device);
                    try! realm?.write {
                        self.savedDevices?.devices.remove(objectAtIndex: index!);
                    }
                    self.deviceList.remove(at: self.deviceList.index(of: peripheral)!);
                    self.deviceMap.removeValue(forKey: peripheral.identifier.uuidString);
                    self.centralManager.cancelPeripheralConnection(peripheral);
                }
            }
        } else {
            // it means the device isn't connected and we want to delete it
            for device in (self.savedDevices?.devices)! {
                if device.uuidString == identifier {
                    let index = self.savedDevices?.devices.index(of: device);
                    try! realm?.write {
                        self.savedDevices?.devices.remove(objectAtIndex: index!);
                    }
                }
            }
        }
        self.editingBegin = false;
    }
    
    // Connect to the peripheral was successful
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("--- didConnectPeripheral");
        peripheral.delegate = self;
        self.deviceList.append(peripheral);
        peripheral.discoverServices(nil);
        let data = PeripheralData();
        data.currentValue = 0;
        data.row = self.deviceList.index(of: peripheral)!;
        data.name = peripheral.name;
        data.instantTimestamp = NSDate().timeIntervalSince1970;
        self.readings.append(data);
        self.saveDevice(peripheral, deviceType: DeviceType.UNKNOWN);
        self.appDelegate?.discoverStatus = false;
        for pmdel in self.listeners {
            pmdel.peripheralConnected!(peripheral);
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error) != nil{
            print("!!!--- error in didDiscoverServices: \(error?.localizedDescription)")
        } else {
            
            for service in peripheral.services as [CBService]!{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error) != nil{
            print("!!!--- error in didDiscoverCharacteristicsFor: \(error?.localizedDescription)")
        }
        else {
            
            if service.uuid == heartRateServiceUUID {
                self.devTypeMap[peripheral] = DeviceType.HeartRate;
                // we should update the saved devices
                self.updateDevice(peripheral, deviceTyp: DeviceType.HeartRate);
                for characteristic in service.characteristics! as [CBCharacteristic]{

                    switch characteristic.uuid.uuidString {
                        
                    case PeripheralManager.HEARTRATE_CHARACTERISTIC:
                        // Set notification on heart rate measurement
                        peripheral.setNotifyValue(true, for: characteristic)
                        
                    case PeripheralManager.SENSOR_LOCATION:
                        peripheral.readValue(for: characteristic);
                    case PeripheralManager.MANUFACTURER_NAME:
                        peripheral.setNotifyValue(true, for: characteristic)
                    case PeripheralManager.MODEL_NUMBER:
                        peripheral.setNotifyValue(true, for: characteristic)
                    case "2A39":
                        // Write heart rate control point
                        var rawArray:[UInt8] = [0x01];
                        let data = NSData(bytes: &rawArray, length: rawArray.count)
                        peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                    default:
                        print("characteristics UUID \(characteristic.uuid.uuidString)")
                    }
                }
            } else if service.uuid == powerMeterServiceUUID {
                self.devTypeMap[peripheral] = DeviceType.PowerMeter;
                // we should update the saved devices
                self.updateDevice(peripheral, deviceTyp: DeviceType.PowerMeter);
                for characteristic in service.characteristics! as [CBCharacteristic] {
                    switch characteristic.uuid.uuidString {
                    case PeripheralManager.POWER_CONTROL:
                        var rawArray:[UInt8] = [0x01];
                        let data = NSData(bytes: &rawArray, length: rawArray.count)
                        peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    case PeripheralManager.POWER_MEASUREMENT:
                        peripheral.setNotifyValue(true, for: characteristic);
                        // this should set the cumulative count back to zero
                    case PeripheralManager.POWER_FEATURE:
                        peripheral.setNotifyValue(true, for: characteristic);
                    case PeripheralManager.TEMPERATURE_MEASUREMENT:
                        peripheral.setNotifyValue(true, for: characteristic);
                    default:
                        peripheral.setNotifyValue(true, for: characteristic);
                    }
                }
            } else if service.uuid == speedCadenceServiceUUID {
                self.devTypeMap[peripheral] = DeviceType.SpeedCadence;
                self.speedSensor = peripheral;
                self.updateDevice(peripheral, deviceTyp: DeviceType.SpeedCadence);
                for characteristic in service.characteristics! as [CBCharacteristic] {
                    switch characteristic.uuid.uuidString {
                    case PeripheralManager.SPEED_CHARACTERISTIC:
                        peripheral.setNotifyValue(true, for: characteristic);
                    case PeripheralManager.SPEED_CADENCE_CONTROL:
                        cscControlCharacteristic = characteristic;
                        self.resetSpeedCummulative();
                    default:
                        peripheral.setNotifyValue(true, for: characteristic);
                    }
                }
            } else if service.uuid == batteryServiceUUID {
                for characteristic in service.characteristics! as [CBCharacteristic] {
                    switch characteristic.uuid.uuidString {
                    case PeripheralManager.BATTERY_LEVEL:
                        peripheral.setNotifyValue(true, for: characteristic);
                    case PeripheralManager.BATTERY_LEVEL_STATE:
                        peripheral.setNotifyValue(true, for: characteristic);
                    default:
                        peripheral.setNotifyValue(true, for: characteristic);
                    }
                }
            } else if service.uuid == deviceInfoServiceUUID {
                for characteristic in service.characteristics! as [CBCharacteristic] {
                    switch characteristic.uuid.uuidString {
                    case PeripheralManager.MANUFACTURER_NAME:
                        peripheral.setNotifyValue(true, for: characteristic);
                    default:
                        peripheral.setNotifyValue(true, for: characteristic);
                    }
                }
            } else {
                print(" // ---------- service: \(service.uuid)");
                for characteristic in service.characteristics! as [CBCharacteristic] {
                    //peripheral.setNotifyValue(true, for: characteristic);
                    print(" //// ---- characteristic: \(characteristic)");
                }
            }
        }
    }
    
    func resetSpeedCummulative() {
        var rawArray:[Int16] = [0x01];
        let data = NSData(bytes: &rawArray, length: rawArray.count)
        self.speedSensor?.writeValue(data as Data, for: self.cscControlCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    func update(_ peripheral:CBPeripheral, heartRateData:Data){
        var buffer = [UInt8](repeating: 0x00, count: heartRateData.count)
        heartRateData.copyBytes(to: &buffer, count: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            } else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBpm = bpm {
            let index = self.deviceList.index(of: peripheral);
            let reading = self.readings[index!] as! PeripheralData;
            reading.currentValue = Int16(actualBpm);
            reading.deviceType = DeviceType.HeartRate;
            reading.instantTimestamp = NSDate().timeIntervalSince1970;
            self.notifyDelegates(reading);
        }
    }
    
    func updatePower(_ peripheral:CBPeripheral, powerData:Data) {
        let ts = NSDate().timeIntervalSince1970;
        var pwrReading:Int16 = 0;
        // the first 16bits contains the data for the flags
        // The next 16bits make up the power reading
        pwrReading = readInteger(data: powerData as NSData, start: 2);
        let index = self.deviceList.index(of: peripheral);
        let reading = self.readings[index!] as! PeripheralData;
        reading.currentValue = pwrReading;
        reading.deviceType = DeviceType.PowerMeter;
        reading.instantTimestamp = ts;
        self.notifyDelegates(reading);
    }
    
    func readInteger<T : Integer>(data : NSData, start : Int) -> T {
        var d : T = 0;
        data.getBytes(&d, range: NSRange(location: start, length: MemoryLayout<T>.size))
        return d
    }

    func updateBattery(_ peripheral:CBPeripheral, value:Data){
        let ts = NSDate().timeIntervalSince1970;
        var buffer = [UInt8](repeating: 0x00, count: value.count)
        value.copyBytes(to: &buffer, count: buffer.count)
        
        let batlevel = UInt8(buffer[0]);
        let index = self.deviceList.index(of: peripheral);
        let reading = self.readings[index!] as! PeripheralData;
        reading.currentValue = Int16(batlevel);
        reading.batteryLevel = batlevel;
        reading.instantTimestamp = ts;
        self.notifyDelegates(reading);
    }
    
    func updateSpeed(_ peripheral:CBPeripheral, value:Data) {
        let ts = NSDate().timeIntervalSince1970;
        
        // first 8 bytes are flags
        // second 32 bytes is revolutions
        var wheelrev:UInt32 = 0;
        var lastwheel:UInt16 = 0;
        var crankrev:UInt16 = 0;
        var lastcrank:UInt16 = 0;
        let index = self.deviceList.index(of: peripheral);
        let reading = self.readings[index!] as! PeripheralData;

        wheelrev = readInteger(data: value as NSData, start: 1);
        lastwheel = readInteger(data: value as NSData, start: 5);
        let wheelEvent = Double(lastwheel) / 1024.0;
        reading.deviceType = DeviceType.SpeedCadence;
        reading.instantTimestamp = ts;
        reading.speed = self.calculateSpeed(wheelrev, currentEvent: wheelEvent, circumferencemm: self.circumference);
        // only try to get cadence if the buffer count is great than 8
        /**
        if buffer.count > 7 {
            crankrev = readInteger(data: value as NSData, start: 7);
            lastcrank = readInteger(data: value as NSData, start: 9);
            let crankEvent = Double(lastcrank) / 1024.0;
            reading.cadence = self.calculateCrankRPM(crankrev, currentEvent: crankEvent);
        } **/
        //print("revs: \(crankrev) - last: \(lastcrank) - rpm: \(reading.cadence)");
        self.notifyDelegates(reading);
    }
    
    func calculateSpeed(_ currentRev:UInt32, currentEvent:Double, circumferencemm:Int16) -> Double {
        let deltaRevs = currentRev - self.previousRevolutionCount;
        let deltaWheelEvent = currentEvent - self.previousWheelEvent;
        var speed = 0.0;
        if deltaWheelEvent > 0.0 && deltaRevs > 0 {
            // speed = (circumfereMeters * revolutions) / timeSinceLastReading
            // to get Kmh = speed x 3.6
            // to get mph = speed x 2.237
            // according to BTLE spec time is 1/1024 second resolution
            // we multiply by 1.024 to get milliseconds for better accuracy
            speed = (((Double(circumferencemm) * 0.001) * Double(deltaRevs)) / (deltaWheelEvent * 1.024));
            // We keep count of the revolutions to calculate the total distance at the end
            self.workoutRevolutionCount += Int32(deltaRevs);
        }
        self.previousRevolutionCount = currentRev;
        self.previousWheelEvent = currentEvent;
        // sometimes the speed sensor can give crazy readings
        // we filter that out by having the max be 40 mps, which is 90mph
        if speed > 0.0 && speed < 40.00 {
            self.currentSpeedMetersPerSec = speed;
        } else {
            self.currentSpeedMetersPerSec = 0.0;
        }
        return self.currentSpeedMetersPerSec;
    }
    
    func calculateCrankRPM(_ currentRev:UInt16, currentEvent:Double) -> Int16 {
        let deltaRevs = currentRev - self.previousCrankRevolutionCount;
        let deltaCrankEvent = currentEvent - self.previousCrankEvent;
        var rpm:Int16 = 0;
        if deltaRevs > 0 && deltaCrankEvent > 0 {
            rpm = Int16(Int(( Double(deltaRevs)/deltaCrankEvent) * 60));
        }
        if currentRev > self.previousCrankRevolutionCount {
            self.previousCrankRevolutionCount = currentRev;
            self.previousCrankEvent = currentEvent;
        }
        return rpm;
    }
    
    func updateSensorLocation(_ peripheral:CBPeripheral, value:Data) {
        let index = self.deviceList.index(of: peripheral);
        let dev = self.savedDevices?.devices[index!];
        /**
         0	Other
         1	Chest
         2	Wrist
         3	Finger
         4	Hand
         5	Ear Lobe
         6	Foot
         **/
        var loc:Int8 = 0;
        loc = readInteger(data: value as NSData, start: 0);
        try! realm?.write {
            switch loc {
            case 1:
                dev?.sensorLocation = "Chest";
            case 2:
                dev?.sensorLocation = "Wrist";
            case 6:
                dev?.sensorLocation = "Foot";
            default:
                dev?.sensorLocation = "Other";
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (error) != nil{
            
        } else {
            if !self.editingBegin {
                switch characteristic.uuid.uuidString {
                case "2A37":
                    update(peripheral, heartRateData:characteristic.value!)
                case "2A63":
                    updatePower(peripheral, powerData:characteristic.value!)
                case PeripheralManager.BATTERY_LEVEL:
                    updateBattery(peripheral, value: characteristic.value!)
                case PeripheralManager.SPEED_CHARACTERISTIC:
                    updateSpeed(peripheral, value: characteristic.value!);
                case PeripheralManager.MANUFACTURER_NAME:
                    print("\(String(describing: characteristic.value))");
                case PeripheralManager.MODEL_NUMBER:
                    print("\(String(describing: characteristic.value))");
                case PeripheralManager.SENSOR_LOCATION:
                    updateSensorLocation(peripheral, value: characteristic.value!)
                case PeripheralManager.BATTERY_LEVEL_STATE:
                    updateBattery(peripheral, value: characteristic.value!)
                default:
                    print("--- something other than 2A37 uuid characteristic: \(characteristic.uuid)")
                }
            }
        }
    }

    func notifyDelegates(_ data:PeripheralData) {
        for delegate in self.listeners {
            delegate.updatedValue(data);
        }
    }
}
