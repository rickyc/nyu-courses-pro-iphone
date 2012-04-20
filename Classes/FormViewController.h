//
//  FormViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailedViewController.h"
#import "JSON.h"

@interface FormViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {
	UITableView *coursesTableView;
	UISearchBar *searchBar;
	UISearchDisplayController *searchDisplayController;
	
	NSMutableData *receivedData;
	NSXMLParser *registrarParser;
	
	NSMutableArray *filteredCourses;
	NSMutableArray *courses;
	
	UIActivityIndicatorView * activityIndicator;
	UIBarButtonItem *navigationRightItem;
	UIBarButtonItem *hideShowInstructorButton;
	
	NSString *oldQuery;
	
	DetailedViewController *detailedViewController;
	
	NSInteger pagination;
    BOOL filterMode;
}

@property(nonatomic, retain) UITableView *coursesTableView;
@property(nonatomic, retain) UISearchBar *searchBar;
@property(nonatomic, retain) UISearchDisplayController *searchDisplayController;

@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@property(nonatomic, retain) NSString *oldQuery;
@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, retain) NSXMLParser *registrarParser;
@property(nonatomic, retain) NSMutableArray *courses;
@property(nonatomic, retain) NSMutableArray *filteredCourses;

@property(nonatomic, retain) UIBarButtonItem *navigationRightItem;
@property(nonatomic, retain) UIBarButtonItem *hideShowInstructorButton;

@property(nonatomic, retain) DetailedViewController *detailedViewController;

@property (nonatomic, assign) BOOL filterMode;

- (void)launchURL:(NSString*)url;
- (void)getCourseContents;
- (void)showNoDataAlert;

@end
