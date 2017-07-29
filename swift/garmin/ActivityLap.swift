//
//  ActivityLap.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

class ActivityLap: Object {
    dynamic var totalTimeSeconds:Double = Double(0.0);
    dynamic var distanceMeters:Double = Double(0.0);
    dynamic var maximumSpeed:Double = Double(0.0);
    var calories:Int?
    dynamic var averageHeartRateBpm:HeartRateInBeatsPerMinute?
    dynamic var maximumHeartRateBpm:HeartRateInBeatsPerMinute?
    dynamic var intensity:String?
    var cadence:Int?
    dynamic var triggerMethod:String?
    var track = List<Track>()
    dynamic var notes:String?
    dynamic var extensions:Extensions?
    dynamic var startTime:Date?
    dynamic var averagePowerWatts:Int = 0;
    
    func addTrack(_ track:Track) {
        self.track.append(track);
    }
    
    func toParams() -> Dictionary<String, AnyObject> {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        var params = Dictionary<String, AnyObject>();
        params["totalTimeSeconds"] = self.totalTimeSeconds as AnyObject;
        params["distanceMeters"] = self.distanceMeters as AnyObject;
        params["maximumSpeed"] = self.maximumSpeed as AnyObject;
        params["calories"] = self.calories as AnyObject;
        params["averageHeartRateBpm"] = self.averageHeartRateBpm?.toParams() as AnyObject;
        params["maximumHeartRateBpm"] = self.maximumHeartRateBpm?.toParams() as AnyObject;
        params["intensity"] = self.intensity as AnyObject;
        params["cadence"] = self.cadence as AnyObject;
        params["triggerMethod"] = self.triggerMethod as AnyObject;
        var tracklist = [AnyObject]();
        for tr in self.track {
            tracklist.append(tr.toParams() as AnyObject);
        }
        params["track"] = tracklist as AnyObject;
        params["notes"] = self.notes as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        params["startTime"] = dateFormatter.string(from:self.startTime!) as AnyObject;
        params["averagePowerWatts"] = self.averagePowerWatts as AnyObject;
        return params;
    }
}
