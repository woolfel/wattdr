//
//  Week.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class Week: Object {
    dynamic var notes:String?
    dynamic var startDay:Date?
    
    func toParams() -> Dictionary<String, AnyObject> {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        var params = Dictionary<String, AnyObject>();
        params["notes"] = self.notes as AnyObject;
        if let sd = self.startDay {
            params["startDay"] = dateFormatter.string(from: sd) as AnyObject;
        }
        return params;
    }
}
