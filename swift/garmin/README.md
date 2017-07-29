# Garmin TCX

I had to extend Garmin TCX with some additional fields to record millisecond timestamps. All of the objects extend Realm Object, to make it easy to persist the objects and read them back.

ActivityTrackpointExtension has 2 additional fields: timestamp and powerMeterName.

Trackpoint has 2 additional fields: timestamp and speed.

When WattDr exports the workout session, it includes these additional fields.