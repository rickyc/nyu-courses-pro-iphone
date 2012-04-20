//
//  InstructorRatingViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/3/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchXML.h"
#import "BrowserViewController.h"

@interface InstructorRatingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *instructorTableView;
	
	NSString *instructorName;
	NSMutableArray *courseList;
	
	UIActivityIndicatorView *activityIndicator;
	BrowserViewController *ratingsWebView;
	
	BOOL loading;
}

@property(nonatomic, retain) NSString *instructorName;
@property(nonatomic, retain) NSMutableArray *courseList;
@property(nonatomic, retain) UITableView *instructorTableView;
@property(nonatomic, retain) BrowserViewController *ratingsWebView;

-(void)grabRSSFeed:(NSString *)urlAddress;

@end