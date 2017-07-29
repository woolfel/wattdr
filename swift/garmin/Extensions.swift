//
//  Extensions.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

public class Extensions: Object {
    // The official XSD defines any as Object, but realm has issues with List<Object>
    // to get around it, changed it to List<ActivityTrackpointExtension>() instead
    var any = List<ActivityTrackpointExtension>()
    
    func toParams() -> Dictionary<String, AnyObject> {
        let sorted = any.sorted(byKeyPath: "powerMeterName", ascending: true);
        var params = Dictionary<String, AnyObject>();
        var atlist = [AnyObject]();
        for ate in sorted {
            atlist.append(ate.toParams() as AnyObject);
        }
        params["any"] = atlist as AnyObject;
        return params;
    }
    
    func sortedExtensions() -> List<ActivityTrackpointExtension> {
        let sorted = List<ActivityTrackpointExtension>();
        let st = any.sorted(byKeyPath: "powerMeterName", ascending: true);
        for ate in st {
            sorted.append(ate);
        }
        return sorted;
    }
}
