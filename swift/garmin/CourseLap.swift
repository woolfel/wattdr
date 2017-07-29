//
//  CourseLap.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class CourseLap: Object {
    dynamic var totalTimeSeconds:Double = 0.0;
    dynamic var distanceMeters:Double = 0.0;
    dynamic var beginPosition:Position?
    dynamic var beginAltitudeMeters:Double = 0.0;
    dynamic var endPosition:Position?
    dynamic var endAltitudeMeters:Double = 0.0;
    dynamic var averageHeartRateBpm:HeartRateInBeatsPerMinute?
    dynamic var maximumHeartRateBpm:HeartRateInBeatsPerMinute?
    dynamic var intensity:String?
    dynamic var cadence:Int = 0;
    dynamic var extensions:Extensions?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["totalTimeSeconds"] = self.totalTimeSeconds as AnyObject;
        params["distanceMeters"] = self.distanceMeters as AnyObject;
        params["beginPosition"] = self.beginPosition?.toParams() as AnyObject;
        params["beginAltitudeMeters"] = self.beginAltitudeMeters as AnyObject;
        params["endPosition"] = self.endPosition?.toParams() as AnyObject;
        params["endAltitudeMeters"] = self.endAltitudeMeters as AnyObject;
        params["averageHeartRateBpm"] = self.averageHeartRateBpm?.toParams() as AnyObject;
        params["maximumHeartRateBpm"] = self.maximumHeartRateBpm?.toParams() as AnyObject;
        params["intensity"] = self.intensity as AnyObject;
        params["cadence"] = self.cadence as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        return params;
    }
}
