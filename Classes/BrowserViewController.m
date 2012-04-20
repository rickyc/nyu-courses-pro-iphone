//
//  BrowserViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/10/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "BrowserViewController.h"

@implementation BrowserViewController
@synthesize browser, url, postData, activityIndicator, scalePages, finished;

- (void)webViewDidStartLoad:(UIWebView *)webView { 

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if (postData == nil)
		[activityIndicator stopAnimating];
}

- (void)viewDidLoad {
	browser.scalesPageToFit = scalePages;
	browser.dataDetectorTypes = UIDataDetectorTypeAll;
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
	[activityIndicator sizeToFit];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
										  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	
	// UIActivityIndicator, adds it to right navigation button
	UIBarButtonItem *navigationRightItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	navigationRightItem.target = self;
	self.navigationItem.rightBarButtonItem = navigationRightItem;
	[navigationRightItem release];
}

- (void)viewDidAppear:(BOOL)animated {
#warning change to root url?
	if([GlobalMethods isNetworkAvailableWithURL:@"http://rickyc.us"]) {
		if(postData == nil) {
			[activityIndicator startAnimating];
			[browser loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
		} else {
			[activityIndicator startAnimating];
	//		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			[browser loadHTMLString:@"<div style='font-size:18px'>Please be patient, the page you have requested is currently loading.</div>" baseURL:nil];
			[NSThread detachNewThreadSelector:@selector(launchURL:) toTarget:self withObject:nil];
		}
	} else
		[GlobalMethods display404ErrorAlert];
}

- (void)launchURL:(id)sender {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSData *data = [postData dataUsingEncoding:NSASCIIStringEncoding];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy 
															timeoutInterval:60];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:data];
	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
	
	if (!connection)
		NSLog(@"no connection, error");
	receivedData = [[NSMutableData data] retain];
	
	// this is used to keep the delegate active
	while (!finished) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	[request release];
	[pool release];
	[[self retain] autorelease];
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Sorry, there was an error establishing a connection" 
												   delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {  
    [receivedData setLength:0];
}  

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];  
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	finished = YES;
//	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSMutableString *dataString = [[[NSMutableString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] autorelease];
	NSLog(@"data - %@",dataString);
	
	[browser loadData:[dataString dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:url]];
	[activityIndicator stopAnimating];
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
	[activityIndicator release];
	[postData release];
	[url release];
	[browser release];
    [super dealloc];
}

@end
