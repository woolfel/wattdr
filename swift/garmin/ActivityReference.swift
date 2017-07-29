//
//  ActivityReference.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class ActivityReference: Object {
    dynamic var id:Date?
    
    func toParams() -> Dictionary<String, AnyObject> {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        var params = Dictionary<String, AnyObject>();
        params["id"] = dateFormatter.string(from: self.id!) as AnyObject;
        return params;
    }
}
