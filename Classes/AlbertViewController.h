//
//  AlbertViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/10/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbertBrowserViewController.h"

@interface AlbertViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *albertTableView;
	NSDictionary *urlDictionary;
	
	AlbertBrowserViewController *browserViewController;
	BOOL even;
}

@property (nonatomic, retain) UITableView *albertTableView;
@property (nonatomic, retain) NSDictionary *urlDictionary;
@property (nonatomic, retain) AlbertBrowserViewController *browserViewController;

@end