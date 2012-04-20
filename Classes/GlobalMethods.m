// Copyright (c) 2009 Ricky Cheng
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
//  GlobalMethods.m
//
//  Created by Ricky Cheng
//  Copyright 2009 Ricky Cheng. All rights reserved.
//

#import "GlobalMethods.h"

@implementation GlobalMethods

+ (void)displayNoNetworkAlert {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Connectivity" message:@"Sorry, please check your network connection "
						  "and try again." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];	
}

+ (void)display404ErrorAlert {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"404 Error" message:@"Sorry, a problem has occurred with "
						  "your URL request. Please try again at a later time." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];
	[alert release];	
}

+ (BOOL)isNetworkAvailableWithURL:(NSString*)url {
	NSString *theURL = [NSString stringWithFormat:url];
	theURL = [theURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:theURL]];
	NSURLResponse *resp = nil;
	NSError *err = nil;
	
	[NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &err];
	
	// no errors means network available
	return (err == nil);
}

+ (NSString*)getStringFromRange:(NSString*)s1 toRange:(NSString*)s2 withString:(NSString*)string includeRange:(BOOL)include {	
	NSRange nRange;
	NSRange r1 = [string rangeOfString:s1];
	NSRange r2 = [string rangeOfString:s2];
	nRange.location = include ? r1.location + r1.length : r1.location;
	nRange.length = include ? r2.location - r1.location - r1.length : r2.location - r1.location;
	return [string substringWithRange:nRange];
}

+ (NSString*)getFavoritesPath {
	return [self getPathByPathComponent:@"course_favorites.plist"];
}

+ (NSString*)getPathByPathComponent:(NSString*)str {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:str];
}

+ (BOOL)doesFileExist:(NSString*)file {
	NSString *path = [self getPathByPathComponent:file];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	return [dict count] > 0;
}

+ (NSString*)convertString:(NSString*)string fromFormat:(NSString*)fromFormat toFormat:(NSString*)toFormat {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:fromFormat];
	
	NSDate *cDate = [dateFormatter dateFromString:string];
	[dateFormatter setDateFormat:toFormat];
	
	NSString *dateString = [dateFormatter stringFromDate:cDate];
	[dateFormatter release];
    
	return dateString; 
}

@end
