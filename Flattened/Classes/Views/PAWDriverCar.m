//
//  PAWDriverCar.m
//  taxi
//
//  Created by ALEX on 2014/4/9.
//  Copyright (c) 2014年 Miiitech. All rights reserved.
//

#import "PAWDriverCar.h"

@interface PAWDriverCar()

// Redefine these properties to make them read/write for internal class accesses and mutations.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString    *title;
@property (nonatomic, copy) NSString    *subtitle;
@property (nonatomic, copy) NSString    *objectID;

@property (nonatomic, strong) PFObject      *object;
@property (nonatomic, strong) PFGeoPoint    *geopoint;
@property (nonatomic, strong) PFUser        *user;

@end


@implementation PAWDriverCar
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize objectID;

@synthesize object;
@synthesize geopoint;
@synthesize user;


- (id) initWithCoordinate:(CLLocationCoordinate2D)aCoordinate andTitle:(NSString *)aTitle andSubtitle:(NSString *)aSubtitle andObjectID:(NSString *)anObjectID {
    self = [super init];
	if (self) {
		self.coordinate = aCoordinate;
		self.title = aTitle;
		self.subtitle = aSubtitle;
        self.objectID = anObjectID;
	}
	return self;
}

- (id)initWithPFUser:(PFUser *)aDriver {
	self.user = aDriver;
	self.geopoint = [aDriver objectForKey:kPAPUserLocationLocationKey];
    
    /*!
     Fetches the PFObject's data from the server if isDataAvailable is false.
     */
	[aDriver fetchIfNeeded];
	CLLocationCoordinate2D aCoordinate = CLLocationCoordinate2DMake(self.geopoint.latitude, self.geopoint.longitude);
	NSString *aTitle = [aDriver objectForKey:kPAPUserDisplayNameKey];
	NSString *aSubtitle = [aDriver objectForKey:kPAPUserDisplayNameKey];
    NSString *anObjectID = aDriver.objectId;
	return [self initWithCoordinate:aCoordinate andTitle:aTitle andSubtitle:aSubtitle andObjectID:anObjectID];
}

- (BOOL)equalToCar:(PAWDriverCar *)aCar{
    if (aCar == nil) {
		return NO;
	}
    
	if (aCar.user && self.user) {
		// We have a PFObject inside the PAWPost, use that instead.
		if ([aCar.user.objectId compare:self.user.objectId] != NSOrderedSame) {
			return NO;
		}
		return YES;
	} else {
		// Fallback code:
		NSLog(@"%s Testing equality of PAWPosts where one or both objects lack a backing PFObject", __PRETTY_FUNCTION__);
        
		if ([aCar.title    compare:self.title]    != NSOrderedSame ||
			[aCar.subtitle compare:self.subtitle] != NSOrderedSame ||
			aCar.coordinate.latitude  != self.coordinate.latitude ||
			aCar.coordinate.longitude != self.coordinate.longitude ) {
			return NO;
		}
        
		return YES;
	}
}


- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside {
    self.title = [self.user objectForKey:kPAPUserDisplayNameKey];
    self.subtitle = [self.user objectForKey:kPAPUserDisplayNameKey];
    
	if (outside) {
		self.subtitle = nil;
//		self.title = kPAWWallCantViewPost;
//		self.pinColor = MKPinAnnotationColorRed;
	} else {
		self.subtitle = [self.user objectForKey:kPAPUserDisplayNameKey];
//		self.title = [[self.object objectForKey:kPAPPhotoUserKey] objectForKey:kPAPUserDisplayNameKey];
//		self.pinColor = MKPinAnnotationColorGreen;
	}
}
@end
