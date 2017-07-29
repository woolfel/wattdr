//
//  FirstSport.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

class FirstSport: Object {
    dynamic var activity:Activity?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["activity"] = self.activity?.toParams() as AnyObject;
        return params;
    }
}
