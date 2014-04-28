//
//  PAWDriverCar.h
//  taxi
//
//  Created by ALEX on 2014/4/9.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAWDriverCar : NSObject

// Center latitude and longitude of the annotion view.
// The implementation of this property must be KVO compliant.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// Title and subtitle for use by selection UI.
@property (nonatomic, readonly, copy) NSString      *title;
@property (nonatomic, readonly, copy) NSString      *subtitle;
@property (nonatomic, readonly, copy) NSString      *objectID;

// Other properties:
@property (nonatomic, readonly, strong) PFObject *object;
@property (nonatomic, readonly, strong) PFGeoPoint *geopoint;
@property (nonatomic, readonly, strong) PFUser *user;

// Designated initializer.
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title andSubtitle:(NSString *)subtitle andObjectID:(NSString *)objectID;
- (id)initWithPFUser:(PFUser *)aDriver;
- (BOOL)equalToCar:(PAWDriverCar *)aCar;

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside;
@end
