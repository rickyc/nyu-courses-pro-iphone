//
//  AdvancedSearchViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 10/10/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "AdvancedSearchViewController.h"

#define kStartTimeSwitchTag 0
#define kEndTimeSwitchTag	1
#define kEnabled			0
#define kDisabled			1
#define kSQLFormat			@"yyyy-MM-dd HH:mm:ss"
#define k24HourFormat		@"HH:mm:ss"
#define kStandardTimeFormat @"hh:mm a"

@implementation AdvancedSearchViewController
@synthesize searchField, startTime, endTime;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,367)];
	contentView.backgroundColor = [UIColor blackColor];
	self.view = contentView;
	[contentView release];

	UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,-64,320,480)];
	backgroundImage.image = [UIImage imageNamed:@"pinstripe.png"];
	[self.view addSubview:backgroundImage];
	[backgroundImage release];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	searchField = [[UITextField alloc] initWithFrame:CGRectMake(20,20,280,31)];
	searchField.borderStyle = UITextBorderStyleRoundedRect;
	searchField.placeholder = @"Search By";
	searchField.text = [prefs stringForKey:@"search_string"];
	searchField.adjustsFontSizeToFitWidth = YES;
	searchField.minimumFontSize = 17;
	searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	searchField.font = [UIFont systemFontOfSize:12];
	searchField.keyboardAppearance = UIKeyboardAppearanceAlert;
	searchField.returnKeyType = UIReturnKeyDone;
	searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchField.clearButtonMode =  UITextFieldViewModeWhileEditing;
	searchField.delegate = self;
	[self.view addSubview:searchField];
	
	// add search criterias
	courseNumber = [self getButtonWithFrame:CGRectMake(20,70,138,30) andTitle:@"Course Number"];
	courseNumber.selected = [prefs boolForKey:@"course_number"];
	[self.view addSubview:courseNumber];
	
	courseTitle = [self getButtonWithFrame:CGRectMake(162,70,138,30) andTitle:@"Course Title"];
	courseTitle.selected = [prefs boolForKey:@"course_title"];
	[self.view addSubview:courseTitle];
	
	professor = [self getButtonWithFrame:CGRectMake(20,107,87,30) andTitle:@"Professor"];
	professor.selected = [prefs boolForKey:@"professor"];
	[self.view addSubview:professor];
	
	location = [self getButtonWithFrame:CGRectMake(116,107,87,30) andTitle:@"Location"];
	location.selected = [prefs boolForKey:@"location"];
	[self.view addSubview:location];
	
	callNumber = [self getButtonWithFrame:CGRectMake(213,107,87,30) andTitle:@"Call"];
	callNumber.selected = [prefs boolForKey:@"call_number"];
	[self.view addSubview:callNumber];
	
	// add weekdays
	UILabel *meetingTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,145,120,15)];
	meetingTimeLabel.text = @"Meeting Times:";
	meetingTimeLabel.font = [UIFont boldSystemFontOfSize:12];
	meetingTimeLabel.backgroundColor = [UIColor clearColor];
	meetingTimeLabel.textColor = [UIColor lightGrayColor];
	[self.view addSubview:meetingTimeLabel];
	
	NSInteger y = 170;
	NSInteger l = 33;
	
	mon = [self getDaysButtonWithFrame:CGRectMake(20,y,l,l) andTitle:@"M"];
	mon.selected = [prefs boolForKey:@"m"];
	[self.view addSubview:mon];

	tue = [self getDaysButtonWithFrame:CGRectMake(61,y,l,l) andTitle:@"T"];
	mon.selected = [prefs boolForKey:@"t"];
	[self.view addSubview:tue];
	
	wed = [self getDaysButtonWithFrame:CGRectMake(102,y,l,l) andTitle:@"W"];
	wed.selected = [prefs boolForKey:@"w"];
	[self.view addSubview:wed];
	
	thu = [self getDaysButtonWithFrame:CGRectMake(144,y,l,l) andTitle:@"R"];
	thu.selected = [prefs boolForKey:@"r"];
	[self.view addSubview:thu];
	
	fri = [self getDaysButtonWithFrame:CGRectMake(185,y,l,l) andTitle:@"F"];
	fri.selected = [prefs boolForKey:@"f"];
	[self.view addSubview:fri];
	
	sat = [self getDaysButtonWithFrame:CGRectMake(226,y,l,l) andTitle:@"S"];
	sat.selected = [prefs boolForKey:@"s"];
	[self.view addSubview:sat];
	
	sun = [self getDaysButtonWithFrame:CGRectMake(267,y,l,l) andTitle:@"U"];
	sun.selected = [prefs boolForKey:@"u"];
	[self.view addSubview:sun];
	
	// segemented control
	UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,210,120,15)];
	statusLabel.text = @"Status:";
	statusLabel.font = [UIFont boldSystemFontOfSize:12];
	statusLabel.backgroundColor = [UIColor clearColor];
	statusLabel.textColor = [UIColor lightGrayColor];
	[self.view addSubview:statusLabel];
	
	courseStatus = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All",@"Open",@"Closed",@"Canceled",nil]];
	courseStatus.frame = CGRectMake(20,230,280,30);
	courseStatus.segmentedControlStyle = UISegmentedControlStyleBar;
	courseStatus.selectedSegmentIndex = [prefs integerForKey:@"course_status_index"];
	courseStatus.tintColor = [UIColor darkGrayColor];
	[self.view addSubview:courseStatus];

	// time manipulation
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:k24HourFormat];

	// date is in string format HH:mm:ss
	NSString *s = [prefs objectForKey:@"start_time"];
	NSString *sTime = @"";
	if(s != nil && ![s isEqualToString:@""]) {
		sTime = [GlobalMethods convertString:s fromFormat:k24HourFormat toFormat:kStandardTimeFormat];
		startTime = [[dateFormatter dateFromString:s] retain];
	}
	
	NSString *e = [prefs objectForKey:@"end_time"];
	NSString *eTime = @"";
	if(e != nil && ![e isEqualToString:@""]) {
		eTime = [GlobalMethods convertString:e fromFormat:k24HourFormat toFormat:kStandardTimeFormat];
		endTime = [[dateFormatter dateFromString:e] retain];
	}
	[dateFormatter release];
	
	// start & end time
	startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(19,280,120,15)];
	startTimeLabel.text = [NSString stringWithFormat:@"Start Time: %@",sTime];
	startTimeLabel.font = [UIFont boldSystemFontOfSize:12];
	startTimeLabel.backgroundColor = [UIColor clearColor];
	startTimeLabel.textColor = [UIColor lightGrayColor];
	[self.view addSubview:startTimeLabel];

	endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(167,280,120,15)];
	endTimeLabel.text = [NSString stringWithFormat:@"End Time: %@",eTime];
	endTimeLabel.font = [UIFont boldSystemFontOfSize:12];
	endTimeLabel.backgroundColor = [UIColor clearColor];
	endTimeLabel.textColor = [UIColor lightGrayColor];
	[self.view addSubview:endTimeLabel];
	
	[self initTimeSwitches];
	
	// restore default
	UIButton *restoreDefaults = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	restoreDefaults.frame = CGRectMake(20,355,280,37);
	[restoreDefaults setBackgroundImage:[UIImage imageNamed:@"mainButton.png"] forState:UIControlStateNormal];
//	[restoreDefaults setBackgroundImage:[UIImage imageNamed:@"cellSelected.png"] forState:UIControlStateHighlighted];
	[restoreDefaults setTitle:@"Restore Defaults" forState:UIControlStateNormal];
	[restoreDefaults addTarget:self action:@selector(restoreDefaults:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:restoreDefaults];
}

- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:YES forKey:@"changed"];
}

- (void)initTimeSwitches {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSString *s = [prefs objectForKey:@"start_time"];
	NSString *e = [prefs objectForKey:@"end_time"];
	
	startTimeSwitch = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Enable",@"Disable",nil]];
	startTimeSwitch.frame = CGRectMake(19,300,133,30);
	startTimeSwitch.selectedSegmentIndex = s == nil || [s isEqualToString:@""] ? kDisabled : kEnabled;
	startTimeSwitch.segmentedControlStyle = UISegmentedControlStyleBar;
	startTimeSwitch.tintColor = [UIColor darkGrayColor];
	startTimeSwitch.tag = kStartTimeSwitchTag;
	[startTimeSwitch addTarget:self action:@selector(launchTimePicker:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:startTimeSwitch];
		
	endTimeSwitch = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Enable",@"Disable",nil]];
	endTimeSwitch.frame = CGRectMake(167,300,133,30);
	endTimeSwitch.segmentedControlStyle = UISegmentedControlStyleBar;
	endTimeSwitch.tintColor = [UIColor darkGrayColor];
	endTimeSwitch.selectedSegmentIndex = e == nil || [e isEqualToString:@""] ? kDisabled :kEnabled;
	endTimeSwitch.tag = kEndTimeSwitchTag;
	[endTimeSwitch addTarget:self action:@selector(launchTimePicker:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:endTimeSwitch];
}

// defaults
- (void)restoreDefaults:(id)sender {
	searchField.text = @"";
	courseNumber.selected = courseTitle.selected = professor.selected = location.selected = callNumber.selected = mon.selected =
	tue.selected = wed.selected = thu.selected = fri.selected = sat.selected = sun.selected = NO;
	
	startTimeLabel.text = @"Start Time:";
	endTimeLabel.text = @"End Time:";
	
	[startTimeSwitch release];
	[endTimeSwitch release];
	[self initTimeSwitches];
	
	[startTime release];
	[endTime release];
	
	courseStatus.selectedSegmentIndex = 0;
	
	startTime = nil;
	endTime = nil;
}

- (void)launchTimePicker:(id)sender {
	UISegmentedControl *control = (UISegmentedControl*)sender;
	
	if(control.selectedSegmentIndex == kEnabled) {
		NSString *actionSheetTitle = control.tag == kStartTimeSwitchTag ? @"Start Time" : @"End Time";
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle delegate:self cancelButtonTitle:@"Done" destructiveButtonTitle:nil otherButtonTitles:nil];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:k24HourFormat];
		NSDate *date = [dateFormatter dateFromString:@"08:00:00"];
		
		datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,114,0,0)];
		datePicker.datePickerMode = UIDatePickerModeTime;
		datePicker.minuteInterval = 15;
		datePicker.date = date; 
		datePicker.tag = control.tag;
		[actionSheet addSubview:datePicker];
		[actionSheet showInView:self.view];
		[actionSheet setBounds:CGRectMake(0,0,320,550)];
	} else {
		if(control.tag == kStartTimeSwitchTag) {
			startTimeLabel.text = @"Start Time:";
			startTime = nil;
		} else {
			endTimeLabel.text = @"End Time:";
			endTime = nil;
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSString *time = [GlobalMethods convertString:[datePicker.date description] fromFormat:kSQLFormat toFormat:@"hh:mm a"];
	if(datePicker.tag == kStartTimeSwitchTag) {
		startTime = datePicker.date;
		startTimeLabel.text = [NSString stringWithFormat:@"%@ %@", @"Start Time:", time];
	} else {
		NSComparisonResult result = [startTime compare:datePicker.date];
		if(startTime == nil || result == NSOrderedAscending) {
			endTime = datePicker.date;
			endTimeLabel.text = [NSString stringWithFormat:@"%@ %@", @"End Time:", time];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The end time you have chose was greater than the start time." 
														   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alert show];
			[alert release];
			endTimeSwitch.selectedSegmentIndex = kDisabled;
		}
	}
	
	[datePicker release];
	
}

- (UIButton*)getButtonWithFrame:(CGRect)frame andTitle:(NSString*)buttonTitle {
	UIButton *btn = [[UIButton alloc] initWithFrame:frame];
	btn.backgroundColor = [UIColor clearColor];
	[btn setTitle:buttonTitle forState:UIControlStateNormal];
	[btn setTitle:buttonTitle forState:UIControlStateSelected];
	btn.titleLabel.textColor = [UIColor whiteColor];
	btn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	[btn setBackgroundImage:[[UIImage imageNamed:@"blackButton.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8] forState:UIControlStateNormal];
	[btn setBackgroundImage:[[UIImage imageNamed:@"blackButtonSelected.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8] forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(toggleCriterias:) forControlEvents:UIControlEventTouchUpInside];
	
	return btn;
}

- (UIButton*)getDaysButtonWithFrame:(CGRect)frame andTitle:(NSString*)buttonTitle {
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
	btn.titleLabel.textColor = [UIColor whiteColor];
	btn.frame = frame;
	[btn setTitle:buttonTitle forState:UIControlStateNormal];
	[btn setTitle:buttonTitle forState:UIControlStateSelected];
	[btn setBackgroundImage:[UIImage imageNamed:@"daysBackground.png"] forState:UIControlStateNormal];
	[btn setBackgroundImage:[UIImage imageNamed:@"daysBackgroundSelected.png"] forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(toggleDayButton:) forControlEvents:UIControlEventTouchUpInside];
	
	return btn;
}

- (void)toggleDayButton:(id)sender {
	UIButton *button = (UIButton*)sender;
	button.selected = !button.selected;
}

- (void)toggleCriterias:(id)sender {
	UIButton *button = (UIButton*)sender;
	button.selected = !button.selected;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *searchString = searchField.text == nil ? @"" : searchField.text;
	
	// if all the fields are not selected
	if(![searchString isEqualToString:@""] && !courseNumber.selected && !courseTitle.selected && !professor.selected 
	   && !location.selected && !callNumber.selected) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You have not selected a criteria for the search. "
							  "Please choose one of the following options (course number, course title, etc.)." delegate:self cancelButtonTitle:@"Dismiss" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[prefs setObject:searchString forKey:@"search_string"];
	[prefs setBool:courseNumber.selected forKey:@"course_number"];
	[prefs setBool:courseTitle.selected forKey:@"course_title"];
	[prefs setBool:professor.selected forKey:@"professor"];
	[prefs setBool:location.selected forKey:@"location"];
	[prefs setBool:callNumber.selected forKey:@"call_number"];

	[prefs setBool:mon.selected forKey:@"m"];
	[prefs setBool:tue.selected forKey:@"t"];
	[prefs setBool:wed.selected forKey:@"w"];
	[prefs setBool:thu.selected forKey:@"r"];
	[prefs setBool:fri.selected forKey:@"f"];
	[prefs setBool:sat.selected forKey:@"s"];
	[prefs setBool:sun.selected forKey:@"u"];

	[prefs setObject:[courseStatus titleForSegmentAtIndex:courseStatus.selectedSegmentIndex] forKey:@"course_status"];
	[prefs setInteger:courseStatus.selectedSegmentIndex forKey:@"course_status_index"];
	
	NSString *sTime = startTime == nil ? @"" : [GlobalMethods convertString:[startTime description] fromFormat:kSQLFormat toFormat:k24HourFormat];
	NSString *eTime = endTime == nil ? @"" : [GlobalMethods convertString:[endTime description] fromFormat:kSQLFormat toFormat:k24HourFormat];
	
	// date stored as string in format HH:mm:ss
	[prefs setObject:sTime forKey:@"start_time"];
	[prefs setObject:eTime forKey:@"end_time"];

	[searchField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[mon release];
	[tue release];
	[wed release];
	[thu release];
	[fri release];
	[sat release];
	[sun release];
	[courseStatus release];
	[datePicker release];
	[startTimeSwitch release];
	[endTimeSwitch release];
	[startTimeLabel release];
	[endTimeLabel release];
	[startTime release];
	[endTime release];
	[callNumber release];
	[location release];
	[professor release];
	[courseTitle release];
	[courseNumber release];
	[searchField release];
    [super dealloc];
}


@end
