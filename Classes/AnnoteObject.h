//
//  AnnoteObject.h
//  NYU Registrar
//
//  Created by Ricky Cheng on 6/23/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AnnoteObject : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *subtitle;
	NSString *title;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *title;

-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end