//
//  HeartRateInBeatsPerMinute.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

class HeartRateInBeatsPerMinute: Object {
    dynamic var value:Int16 = 0;
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["value"] = self.value as AnyObject;
        return params;
    }
}
