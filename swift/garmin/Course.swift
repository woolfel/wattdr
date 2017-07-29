//
//  Course.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class Course: Object {
    dynamic var name:String?
    var lap = List<CourseLap>()
    var track = List<Track>()
    dynamic var notes:String?
    var coursePoint = List<CoursePoint>()
    dynamic var creator:AbstractSource?
    dynamic var extensions:Extensions?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["name"] = self.name as AnyObject;
        var clist = [AnyObject]();
        params["lap"] = clist as AnyObject;
        for cl in lap {
            clist.append(cl.toParams() as AnyObject);
        }
        var tlist = [AnyObject]();
        params["track"] = tlist as AnyObject;
        for tr in track {
            tlist.append(tr.toParams() as AnyObject);
        }
        params["notes"] = self.notes as AnyObject;
        var crlist = [AnyObject]();
        params["coursePoint"] = crlist as AnyObject;
        for cp in self.coursePoint {
            crlist.append(cp.toParams() as AnyObject);
        }
        params["creator"] = self.creator?.toParams() as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        return params;
    }
}
