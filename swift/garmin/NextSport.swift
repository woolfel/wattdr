//
//  NextSport.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class NextSport: Object {
    dynamic var transition:ActivityLap?
    dynamic var activity:Activity?
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["transition"] = self.transition?.toParams() as AnyObject;
        params["activity"] = self.activity?.toParams() as AnyObject;
        return params;
    }
}
