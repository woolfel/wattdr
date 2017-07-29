//
//  Courses.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

class Courses: Object {
    dynamic var courseFolder:CourseFolder?
    dynamic var extensions:Extensions?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["courseFolder"] = self.courseFolder?.toParams() as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        return params;
    }
}
