//
//  LoginViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/3/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbertViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UIImageView *homeImageView;
	IBOutlet UIButton *removeKeyboardButton;
	IBOutlet UIButton *loginButton;
	IBOutlet UITextField *netid;
	IBOutlet UITextField *password;
	
	NSMutableData *receivedData;
	NSString *routerCode;
	AlbertViewController *avc;
	
	UIActivityIndicatorView *activityIndicator;
	UIBarButtonItem *clearItemButton;
	UIBarButtonItem *navigationRightItem;
	int counter;
}

@property(nonatomic, retain) UIImageView *homeImageView;
@property(nonatomic, retain) UIButton *removeKeyboardButton;
@property(nonatomic, retain) UIButton *loginButton;
@property(nonatomic, retain) UITextField *netid;
@property(nonatomic, retain) UITextField *password;
@property(nonatomic, retain) NSMutableData *receivedData;
@property(nonatomic, retain) NSString *routerCode;
@property(nonatomic, retain) AlbertViewController *avc;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, retain) UIBarButtonItem *clearItemButton;
@property(nonatomic, retain) UIBarButtonItem *navigationRightItem;

- (IBAction)removeKeyboard:(id)sender;
- (IBAction)loginToNYUHome:(id)sender;

- (void)connectToURL:(NSString*)url withPost:(NSString*)post;
- (void)loginSuccessfulWithDictionary:(NSDictionary*)dictionary;

@end