//
//  Track.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

class Track: Object {
    var trackpoint = List<TrackPoint>()
    
    func addTrackPoint(_ newpoint:TrackPoint) {
        self.trackpoint.append(newpoint);
    }
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        var tplist = [AnyObject]();
        for trp in trackpoint {
            tplist.append(trp.toParams() as AnyObject);
        }
        params["trackpoint"] = tplist as AnyObject;
        return params;
    }
}
