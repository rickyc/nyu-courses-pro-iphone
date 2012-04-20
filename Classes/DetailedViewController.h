//
//  DetailedViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/8/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MapViewController.h"
#import "InstructorRatingViewController.h"

@interface DetailedViewController : UIViewController <MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {
	IBOutlet UITextView *courseLabel;
	IBOutlet UILabel *courseNumberLabel;
	IBOutlet UILabel *termLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UILabel *creditLabel;
	IBOutlet UILabel *activityLabel;
	IBOutlet UILabel *callNumberLabel;
	IBOutlet UIButton *siteButton;
	IBOutlet UIButton *locationButton;
	IBOutlet UIButton *instructorButton;
	IBOutlet UILabel *meetingTimesLabel;
	IBOutlet UIToolbar *toolBar;
	
	NSDictionary *activitiesDictionary;
	NSDictionary *sitesDictionary;
	NSDictionary *locationsDictionary;	
	
	NSDictionary *course;
	MapViewController *mapViewController;
	InstructorRatingViewController *instructorRatingViewController;
}

@property(nonatomic, retain) UITextView *courseLabel;
@property(nonatomic, retain) UILabel *courseNumberLabel;
@property(nonatomic, retain) UILabel *termLabel;
@property(nonatomic, retain) UILabel *statusLabel;
@property(nonatomic, retain) UILabel *creditLabel;
@property(nonatomic, retain) UILabel *activityLabel;
@property(nonatomic, retain) UILabel *callNumberLabel;
@property(nonatomic, retain) UIButton *siteButton;
@property(nonatomic, retain) UIButton *locationButton;
@property(nonatomic, retain) UIButton *instructorButton;
@property(nonatomic, retain) UILabel *meetingTimesLabel;
@property(nonatomic, retain) UIToolbar *toolBar;
@property(nonatomic, retain) NSDictionary *course;
@property(nonatomic, retain) NSDictionary *activitiesDictionary;
@property(nonatomic, retain) NSDictionary *sitesDictionary;
@property(nonatomic, retain) NSDictionary *locationsDictionary;
@property(nonatomic, retain) MapViewController *mapViewController;
@property(nonatomic, retain) InstructorRatingViewController *instructorRatingViewController;

- (IBAction)viewInstructorRating:(id)sender;
- (IBAction)viewSiteLocationMap:(id)sender;
- (IBAction)emailCourseInformation:(id)sender;
- (IBAction)launchWebView:(id)sender;
- (void)launchBookstoreData;

@end