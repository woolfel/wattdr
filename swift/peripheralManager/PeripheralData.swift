//
//  PowerData.swift
//  WattDr
//
//  Created by Peter Lin on 7/7/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit

public enum DeviceType: String {
    case HeartRate = "HeartRate";
    case SpeedCadence = "SpeedCadence";
    case PowerMeter = "PowerMeter";
    case UNKNOWN = "Unknown";
}

public class PeripheralData: NSObject {
    var row:Int = 0; // row index is the same as PeripheralManager.devices index
    var currentValue:Int16 = 0;
    var speed:Double = 0.0;
    var cadence:Int16 = 0;
    var instantTimestamp:Double = 0.0;
    var deviceType = DeviceType.PowerMeter;
    var batteryLevel:UInt8 = 0; // not all sensors support battery level, since it is optional
    var name:String?
}
