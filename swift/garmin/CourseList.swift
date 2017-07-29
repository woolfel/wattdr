//
//  CourseList.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class CourseList: Object {
    var course = List<Course>()
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        var clist = [AnyObject]();
        for cr in self.course {
            clist.append(cr.toParams() as AnyObject);
        }
        params["course"] = clist as AnyObject;
        return params;
    }
}
