//
//  TrainingCenterDatabase.swift
//  WattDr
//
//  Created by Peter Lin on 7/10/17.
//  Copyright © 2017 org.woolfel. All rights reserved.
//

import UIKit
import RealmSwift

public class TrainingCenterDatabase: Object {
    dynamic var primaryID = UUID().uuidString;
    dynamic var folders:Folders?
    dynamic var activities:ActivityList?
    dynamic var workouts:WorkoutList?
    dynamic var courses:CourseList?
    dynamic var author:AbstractSource?
    dynamic var extensions:Extensions?
    
    override public static func primaryKey() -> String? {
        return "primaryID"
    }
    
    func initializeDatabase() -> Track {
        self.activities = ActivityList();
        let activity = Activity();
        activity.sport = Sport.BIKING;
        activity.id = Date();
        activity.sport = Sport.BIKING;
        let lap = ActivityLap();
        activity.addLap(lap);
        lap.startTime = Date();
        lap.triggerMethod = TriggerMethod.MANUAL.rawValue;
        let track = Track();
        lap.addTrack(track);
        // add the activity
        self.activities?.addActivity(activity);
        return track;
    }
    
    func addActivity(_ newActivity:Activity) {
        self.activities?.addActivity(newActivity);
    }
    
    func getActivities() -> ActivityList? {
        return activities;
    }
    
    func toParams() -> Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>();
        params["primaryID"] = self.primaryID as AnyObject;
        params["folders"] = self.folders?.toParams() as AnyObject;
        params["activities"] = self.activities?.toParams() as AnyObject;
        params["workouts"] = self.workouts?.toParams() as AnyObject;
        if let crs = self.courses {
            params["courses"] = crs.toParams() as AnyObject;
        }
        if let auth = self.author {
            params["author"] = auth.toParams() as AnyObject;
        }
        if let exten = self.extensions {
            params["extensions"] = exten.toParams() as AnyObject;
        }
        return params;
    }
}
