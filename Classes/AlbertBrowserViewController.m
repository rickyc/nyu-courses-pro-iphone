//
//  AlbertBrowserViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 9/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "AlbertBrowserViewController.h"

@implementation AlbertBrowserViewController

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[activityIndicator stopAnimating];
	NSString *javascript = @"document.documentElement.innerHTML";
	NSString *webContent = [webView stringByEvaluatingJavaScriptFromString:javascript];
	
	NSRange error_1 = [webContent rangeOfString:@"Your access to the system is denied"];
	NSRange error_2 = [webContent rangeOfString:@"please log out of albert"];
	
	if(error_1.length != 0 || error_2.length != 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, an error has occurred, please re-login. If the problem persists please contact us."
													   delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		NSArray *ary = self.navigationController.viewControllers;
		[self.navigationController popToViewController:[ary objectAtIndex:0] animated:NO];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	finished = YES;
	NSMutableString *dataString = [[[NSMutableString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] autorelease];
	
	// special cases
	NSString *newString = [GlobalMethods getStringFromRange:@"<div align=\"center\">" toRange:@"</div><!--" withString:dataString includeRange:YES];
	[browser loadData:[newString dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:url]];
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
    [super dealloc];
}


@end
