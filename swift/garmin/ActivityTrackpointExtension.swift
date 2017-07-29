//
//  ActivityTrackpointExtension.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class ActivityTrackpointExtension: Object {
    dynamic var speed:Double = Double(0.0) // in meters per second
    dynamic var runCadence:Int = 0
    dynamic var watts:Int16 = 0;
    dynamic var extensions:Extensions?
    dynamic var cadenceSensor:String?
    dynamic var powerMeterName:String? // this is a custom field which is not defined by Garmin
    dynamic var timestamp:Double = 0.0;
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["speed"] = self.speed as AnyObject;
        params["runCadence"] = self.runCadence as AnyObject;
        params["watts"] = self.watts as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        params["cadenceSensor"] = self.cadenceSensor as AnyObject;
        params["powerMeterName"] = self.powerMeterName as AnyObject;
        params["timestamp"] = self.timestamp as AnyObject;
        return params;
    }
}
