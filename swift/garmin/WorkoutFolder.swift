//
//  WorkoutFolder.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class WorkoutFolder: Object {
    var folder = List<WorkoutFolder>()
    var workoutNameRef = List<NameKeyReference>()
    dynamic var extensions:Extensions?
    dynamic var name:String?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        var flist = [AnyObject]();
        for wf in self.folder {
            flist.append(wf.toParams() as AnyObject);
        }
        params["folder"] = flist as AnyObject;
        var wnrlist = [AnyObject]();
        for nkr in self.workoutNameRef {
            wnrlist.append( nkr.toParams() as AnyObject );
        }
        params["workoutNameRef"] = wnrlist as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        params["name"] = self.name as AnyObject;
        return params;
    }
}
