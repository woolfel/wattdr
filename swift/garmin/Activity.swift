//
//  Activity.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class Activity: Object {
    dynamic var id:Date?
    var lap = List<ActivityLap>()
    dynamic var notes:String?
    dynamic var training:Training?
    dynamic var creator:AbstractSource?
    dynamic var extensions:Extensions?
    var sport:Sport?
    
    func addLap(_ lap:ActivityLap) {
        self.lap.append(lap);
    }
    
    func toParams() -> Dictionary<String, AnyObject> {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        var params = Dictionary<String, AnyObject>();
        params["id"] = dateFormatter.string(from: self.id!) as AnyObject;
        var laplist = [AnyObject]();
        for l in self.lap {
            laplist.append(l.toParams() as AnyObject);
        }
        params["lap"] = laplist as AnyObject;
        params["notes"] = self.notes as AnyObject;
        params["training"] = nil;
        params["creator"] = self.creator?.toParams() as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        params["sport"] = self.sport as AnyObject;
        return params;
    }
}
