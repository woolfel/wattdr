//
//  HistoryFolder.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class HistoryFolder: Object {
    dynamic var folder:HistoryFolder?
    var activityRef = List<ActivityReference>()
    var week = List<Week>()
    dynamic var notes:String?
    dynamic var extensions:Extensions?
    dynamic var name:String?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["folder"] = self.folder?.toParams() as AnyObject;
        params["notes"] = self.notes as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        params["name"] = self.name as AnyObject;
        var arlist = [AnyObject]();
        for actr in self.activityRef {
            arlist.append(actr.toParams() as AnyObject);
        }
        params["activityRef"] = arlist as AnyObject;
        var wklist = [AnyObject]();
        for wk in self.week {
            wklist.append(wk.toParams() as AnyObject);
        }
        params["week"] = wklist as AnyObject;
        return params;
    }
}
