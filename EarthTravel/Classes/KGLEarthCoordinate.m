//
//  KGLEarthCoordinate.m
//
//  Created by Kevin Li on 3/2/15.
//  Copyright (c) 2015 Kevin Li. All rights reserved.
//

#import "KGLEarthCoordinate.h"

@implementation KGLEarthCoordinate

+ (KGLEarthCoordinate *)coordinateWithLatitude:(float)latitude andLongitude:(float)longitude {
    // no identifier specified, make it nil
    return [KGLEarthCoordinate coordinateWithLatitude:latitude andLongitude:longitude andPinIdentifier:nil andConturyCode:nil];
}

+ (KGLEarthCoordinate *)coordinateWithLatitude:(float)latitude
                                  andLongitude:(float)longitude
                              andPinIdentifier:(NSString *)identifier
                                andConturyCode:(NSString *)conturyCode
{
    KGLEarthCoordinate *coord = [[KGLEarthCoordinate alloc] init];
    if (coord) {
        coord.latitude = latitude;
        coord.longitude = longitude;
        coord.pinIdentifier = identifier;
        coord.contryCode = conturyCode;
    }
    return coord;
}

@end
