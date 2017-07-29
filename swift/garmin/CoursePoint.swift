//
//  CoursePoint.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class CoursePoint: Object {
    dynamic var name:String?
    dynamic var time:Date?
    dynamic var position:Position?
    dynamic var altitudeMeters:Double = Double(0.0);
    dynamic var pointType:String?
    dynamic var notes:String?
    dynamic var extensions:Extensions?
    
    func toParams() -> Dictionary<String, AnyObject> {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
        var params = Dictionary<String, AnyObject>();
        params["named"] = self.name as AnyObject;
        if let t = self.time {
            params["time"] = dateFormatter.string(from: t) as AnyObject;
        }
        params["position"] = self.position?.toParams() as AnyObject;
        params["altitudeMeters"] = self.altitudeMeters as AnyObject;
        params["pointType"] = self.pointType as AnyObject;
        params["notes"] = self.notes as AnyObject;
        params["extensions"] = self.extensions?.toParams() as AnyObject;
        return params;
    }
}
