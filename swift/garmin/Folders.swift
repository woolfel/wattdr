//
//  Folders.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

class Folders: Object {
    dynamic var history:History?
    dynamic var workouts:Workouts?
    dynamic var courses:Courses?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["history"] = self.history?.toParams() as AnyObject;
        params["workouts"] = self.workouts?.toParams() as AnyObject;
        params["courses"] = self.courses?.toParams() as AnyObject;
        return params;
    }
}
