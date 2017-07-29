//
//  MultiSportFolder.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class MultiSportFolder: Object {
    dynamic var folder:MultiSportFolder?
    var multiSportActivityRef = List<ActivityReference>()
    dynamic var week:Week?
    dynamic var notes:String?
    dynamic var extensions:Extensions?
    dynamic var name:String?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        return params;
    }
}
