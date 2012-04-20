//
//  SternInstructorRatingViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 9/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"

@interface SternInstructorRatingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
	UITableView *coursesTableView;
	NSArray *courses;
	NSMutableData *receivedData;
	NSString *urlPath;
	
	UIActivityIndicatorView *activityIndicator;
	UIBarButtonItem *activityIndicatorButton;
	UIBarButtonItem *sternLoginButton;
}

@property(nonatomic, retain) UITableView *coursesTableView;
@property(nonatomic, retain) NSArray *courses;
@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, retain) NSString *urlPath;

- (void)loadJSONFeed;
- (void)retrieveRatingsData;
- (BOOL)shouldAttemptToLogin;
- (NSDictionary*)retrieveDefaultNetidAndPassword;

@end
