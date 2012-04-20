//
//  RatingTableViewCell.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/8/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@interface RatingTableViewCell : ABTableViewCell {
	NSString *courseId;
	NSString *semester;
	NSString *subject;
	BOOL even;
}

@property(nonatomic, copy) NSString *courseId;
@property(nonatomic, copy) NSString *semester;
@property(nonatomic, copy) NSString *subject;
@property(nonatomic, assign) BOOL even;
@end