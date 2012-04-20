//
//  BrowserViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/10/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *browser;
	NSString *url;
	NSString *postData;
	UIActivityIndicatorView *activityIndicator;
	NSMutableData *receivedData;
	BOOL scalePages;
	BOOL finished;
}

@property(nonatomic, retain) UIWebView *browser;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSString *postData;
@property(nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, assign) BOOL scalePages;
@property(nonatomic, assign) BOOL finished;

@end
