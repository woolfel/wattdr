//
//  MultiSportSession.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class MultiSportSession: Object {
    dynamic var id:NSDate?
    dynamic var firstSport:FirstSport?
    var nextSport = List<NextSport>()
    dynamic var notes:String?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["id"] = self.id as AnyObject;
        params["firstSport"] = self.firstSport?.toParams() as AnyObject;
        return params;
    }
}
