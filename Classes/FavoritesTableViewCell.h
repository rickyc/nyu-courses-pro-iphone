//
//  FavoritesTableViewCell.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/11/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@interface FavoritesTableViewCell : ABTableViewCell {
	NSString *courseTitle;
	NSString *instructor;
	NSString *term;
	NSString *date;
	NSString *time;
	NSString *location;
	BOOL even;
}

- (void)setData:(NSDictionary*)course;

@property(nonatomic,retain) NSString *courseTitle;
@property(nonatomic,retain) NSString *instructor;
@property(nonatomic,retain) NSString *term;
@property(nonatomic,retain) NSString *date;
@property(nonatomic,retain) NSString *time;
@property(nonatomic,retain) NSString *location;
@property(nonatomic,assign) BOOL even;

@end