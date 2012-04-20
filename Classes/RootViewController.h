//
//  RootViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormViewController.h"
#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "FavoritesViewController.h"
#import "AdvancedSearchViewController.h"

@interface RootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
	UITableView *form;
	
	FormViewController *resultsViewController;
	SettingsViewController *settingsViewController;
	LoginViewController *loginViewController;
	FavoritesViewController *favoritesViewController;
	AdvancedSearchViewController *advancedSearchViewController;
}

@property(nonatomic, retain) UITableView *form;
@property(nonatomic, retain) FormViewController *resultsViewController;
@property(nonatomic, retain) SettingsViewController *settingsViewController;
@property(nonatomic, retain) LoginViewController *loginViewController;
@property(nonatomic, retain) FavoritesViewController *favoritesViewController;
@property(nonatomic, retain) AdvancedSearchViewController *advancedSearchViewController;

- (void)advancedSearch:(id)sender;
- (void)displayAlbertLoginView:(id)sender;
- (void)displayBookmarks:(id)sender;
- (void)displayAcademicCalendar:(id)sender;
- (void)displayServerStatus:(id)sender;
- (void)displayApplicationInfo:(id)sender;
- (void)launchEmailComposer;

@end