//
//  WorkoutList.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

class WorkoutList: Object {
    dynamic var id:Date?
    dynamic var notes:String?
    dynamic var firstSport:FirstSport?
    var nextSport = List<NextSport>()
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        return params;
    }
}
