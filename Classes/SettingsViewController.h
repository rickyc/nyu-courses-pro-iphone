//
//  SettingsViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLevels 0
#define kSchools 1
#define kSubjects 2
#define kTerms 3

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *settingsTable;
	
	NSArray *terms;
	NSDictionary *levels;
	NSDictionary *schools;
	NSMutableDictionary *subjects;
	NSIndexPath	* lastIndexPath;
	
	int currentSettingIndex;
	int currentSelectedRow;
	
	// Fall 2009
	NSString *currentTerm, *currentLevel, *currentSchool, *currentSubject;
	int currentTermIndex;
}

@property (nonatomic, retain) NSIndexPath *lastIndexPath;

@property(nonatomic, retain) NSString *currentTerm;
@property(nonatomic, retain) NSString *currentLevel;
@property(nonatomic, retain) NSString *currentSchool;
@property(nonatomic, retain) NSString *currentSubject;

@property(nonatomic, assign) int currentSettingIndex;
@property(nonatomic, assign) int currentSelectedRow;
@property(nonatomic, assign) int currentTermIndex;
@property(nonatomic, retain) UITableView *settingsTable;

@property(nonatomic, retain) NSArray *terms;
@property(nonatomic, retain) NSDictionary *levels;
@property(nonatomic, retain) NSDictionary *schools;
@property(nonatomic, retain) NSMutableDictionary *subjects;

- (void)initDefaultArrays;
- (void)initDefaultVars;

- (NSString*)levelValue;
- (NSString*)schoolValue;
- (NSString*)subjectValue;

@end
