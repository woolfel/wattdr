# Garmin TCX

I extended Garmin TCX with some additional fields to record millisecond timestamps and power meter name. All objects extend Realm Object. This makes it easier to save a workout and query the data.

ActivityTrackpointExtension has 2 additional fields: timestamp and powerMeterName.

Trackpoint has 2 additional fields: timestamp and speed.

When WattDr exports the workout session, it includes these additional fields. In the samples folders are two TCX examples recorded with WattDr.