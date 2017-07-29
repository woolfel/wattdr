//
//  Workouts.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class Workouts: Object {
    dynamic var running:WorkoutFolder?
    dynamic var biking:WorkoutFolder?
    dynamic var other:WorkoutFolder?
    dynamic var extensions:Extensions?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["running"] = self.running?.toParams() as AnyObject;
        params["biking"] = self.biking?.toParams() as AnyObject;
        params["other"] = self.other?.toParams() as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        return params;
    }
}
