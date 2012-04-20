//
//  AnnoteObject.m
//  NYU Registrar
//
//  Created by Ricky Cheng on 6/23/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "AnnoteObject.h"


@implementation AnnoteObject
@synthesize coordinate, subtitle, title;


-(id)initWithCoordinate:(CLLocationCoordinate2D) c {
	coordinate = c;
	return self;
}

@end
