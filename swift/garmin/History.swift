//
//  History.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class History: Object {
    dynamic var running:HistoryFolder?
    dynamic var biking:HistoryFolder?
    dynamic var other:HistoryFolder?
    dynamic var multiSport:MultiSportFolder?
    dynamic var extensions:Extensions?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["running"] = self.running?.toParams() as AnyObject;
        params["biking"] = self.biking?.toParams() as AnyObject;
        params["other"] = self.other?.toParams() as AnyObject;
        params["multiSport"] = self.multiSport?.toParams() as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        return params;
    }
}
