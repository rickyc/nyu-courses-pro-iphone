//
//  AdvancedSearchViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 10/10/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvancedSearchViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate> {
	UITextField *searchField;
	
	UIButton *courseNumber;
	UIButton *courseTitle;
	UIButton *professor;
	UIButton *location;
	UIButton *callNumber;
	
	UIButton *mon;
	UIButton *tue;
	UIButton *wed;
	UIButton *thu;
	UIButton *fri;
	UIButton *sat;
	UIButton *sun;

	UISegmentedControl *courseStatus;
	
	UIDatePicker *datePicker;
	
	UISegmentedControl *startTimeSwitch;
	UISegmentedControl *endTimeSwitch;
	
	UILabel *startTimeLabel;
	UILabel *endTimeLabel;
	
	NSDate *startTime;
	NSDate *endTime;
}

@property(nonatomic, retain) UITextField *searchField;
@property(nonatomic, retain) NSDate *startTime;
@property(nonatomic, retain) NSDate *endTime;

- (UIButton*)getButtonWithFrame:(CGRect)frame andTitle:(NSString*)buttonTitle;
- (UIButton*)getDaysButtonWithFrame:(CGRect)frame andTitle:(NSString*)buttonTitle;
- (void)initTimeSwitches;

@end
