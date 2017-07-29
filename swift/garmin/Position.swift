//
//  Position.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class Position: Object {
    var latitudeDegrees:Double = Double(0.0);
    var longitudeDegrees:Double = Double(0.0);
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["latitudeDegrees"] = self.latitudeDegrees as AnyObject;
        params["longitudeDegrees"] = self.longitudeDegrees as AnyObject;
        return params;
    }
}
