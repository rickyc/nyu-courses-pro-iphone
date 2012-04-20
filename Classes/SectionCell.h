//
//  SectionCell.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableViewCell.h"

@interface SectionCell : ABTableViewCell {
	NSString *instructor;
	NSString *time;
	NSString *day;
	NSString *siteLocation;
	BOOL favorite;
	BOOL restricted;
	BOOL even;
}

- (void)setData:(NSDictionary*)course;

@property(nonatomic, copy) NSString *instructor;
@property(nonatomic, copy) NSString *time;
@property(nonatomic, copy) NSString *day;
@property(nonatomic, copy) NSString *siteLocation;
@property(nonatomic, assign) BOOL even;
@property(nonatomic, assign) BOOL restricted;
@property(nonatomic, assign) BOOL favorite;

@end