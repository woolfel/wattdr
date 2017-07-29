//
//  TrackPoint.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class TrackPoint: Object {
    dynamic var time:Date?
    dynamic var timestamp:Double = Double(0.0);
    dynamic var position:Position?
    dynamic var altitudeMeters:Double = Double(0.0);
    dynamic var distanceMeters:Double = Double(0.0);
    dynamic var heartRateBpm:HeartRateInBeatsPerMinute?
    dynamic var cadence:Int8 = 0;
    dynamic var sensorState:String?
    dynamic var extensions:Extensions?
    dynamic var speed:Double = Double(0.0);
    
    func toParams() -> Dictionary<String, AnyObject> {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ";
        var params = Dictionary<String, AnyObject>();
        params["time"] = dateFormatter.string(from: self.time!) as AnyObject;
        params["timestamp"] = self.timestamp as AnyObject;
        params["position"] = self.position?.toParams() as AnyObject;
        params["altitudeMeters"] = self.altitudeMeters as AnyObject;
        params["distanceMeters"] = self.distanceMeters as AnyObject;
        params["heartRateBpm"] = self.heartRateBpm?.toParams() as AnyObject;
        params["cadence"] = self.cadence as AnyObject;
        params["sensorState"] = self.sensorState as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        params["speed"] = self.speed as AnyObject;
        return params;
    }
    
    func SetSpeed() {
        for actext in (self.extensions?.any)! {
            actext.speed = self.speed;
        }
    }
}
