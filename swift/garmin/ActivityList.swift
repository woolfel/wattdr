//
//  ActivityList.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class ActivityList: Object {
    var activity = List<Activity>()
    var multiSportSession = List<MultiSportSession>()
    
    func addActivity(_ newActivity:Activity) {
        self.activity.append(newActivity);
    }
    
    func firstActivity() -> ActivityLap? {
        if let first = activity.first?.lap.first {
            return first;
        }
        return nil;
    }
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        var actlist = [AnyObject]();
        for act in self.activity {
            actlist.append(act.toParams() as AnyObject);
        }
        params["activity"] = actlist as AnyObject;
        var sportlist = [AnyObject]();
        for mss in self.multiSportSession {
            sportlist.append(mss.toParams() as AnyObject);
        }
        params["multiSportSession"] = sportlist as AnyObject;
        return params;
    }
}
