//
//  CourseFolder.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class CourseFolder: Object {
    dynamic var folder:CourseFolder?
    var courseNameRef = List<NameKeyReference>()
    dynamic var notes:String?
    dynamic var extensions:Extensions?
    dynamic var name:String?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["folder"] = self.folder?.toParams() as AnyObject;
        var cnlist = [AnyObject]();
        for nkr in courseNameRef {
            cnlist.append(nkr.toParams() as AnyObject);
        }
        params["courseNameRef"] = cnlist as AnyObject;
        params["notes"] = self.notes as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        params["name"] = self.name as AnyObject;
        return params;
    }
}
