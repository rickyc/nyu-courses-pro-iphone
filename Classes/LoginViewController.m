//
//  AlbertViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/3/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "LoginViewController.h"

@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
	return YES; // Or whatever logic
}
@end

@implementation LoginViewController
@synthesize clearItemButton, activityIndicator, navigationRightItem, homeImageView, loginButton, removeKeyboardButton, netid, password, 
receivedData, routerCode, avc;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// restores the saved password for the previous session
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *netidStr = [prefs stringForKey:@"netid"];
	NSString *passwordStr = [prefs stringForKey:@"password"];
	
	if(netidStr != nil) {
		netid.text = netidStr;
		password.text = passwordStr;
	}
}

- (void)loadNYUHomeImage:(id)sender {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *imageURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://rickyc.us/iphone/nyu/courses/home_image.php"] encoding:NSUTF8StringEncoding error:nil];
	if(imageURL != nil) {
		UIImage* nyuHomeImage = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString:imageURL]]];
		homeImageView.image = nyuHomeImage;
	}
	
	[pool release];
}

- (void)viewDidAppear:(BOOL)animated {
	[NSThread detachNewThreadSelector: @selector(loadNYUHomeImage:) toTarget:self withObject:nil];
	
	clearItemButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearData:)];
	self.navigationItem.rightBarButtonItem = clearItemButton;
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
	[activityIndicator sizeToFit];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
										  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	
	// UIActivityIndicator, adds it to right navigation button
	navigationRightItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	navigationRightItem.target = self;
}

// removes the password from the device and clears the fields
- (void)clearData:(id)sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs removeObjectForKey:@"netid"];
	[prefs removeObjectForKey:@"password"];
	
	netid.text = nil;
	password.text = nil;
	routerCode = nil;
}

// removes the keyboard from view
- (IBAction)removeKeyboard:(id)sender {
	[netid resignFirstResponder];
	[password resignFirstResponder];
}

- (IBAction)loginToNYUHome:(id)sender {
	if(routerCode == nil) {	
		
		NSLog(@"netid => %@, password => %@",netid.text,password.text);
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:netid.text forKey:@"netid"];
		[prefs setObject:password.text forKey:@"password"];
		
		loginButton.enabled = NO;
		
		// loading progress
		self.navigationItem.rightBarButtonItem = navigationRightItem;
		[activityIndicator startAnimating];
		
//		<form   name="Login"  action="/sso/UI/Login?AMAuthCookie=AQIC5wM2LY4SfcwckLBm9%2BuCWu5U9wnwrtRgy0ghFb1SsKE%3D%40AAJTSQACMDIAAlMxAAIwMQ%3D%3D%23"  method="post"> 
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://login.nyu.edu/sso/UI/Login?goto=http://home.nyu.edu:80/cgi-bin/alogin.cgi%%3Fnetid%%3D%@",netid.text]];
		NSString *data = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
		NSLog(@"what is this data? => %@",data);
		if([data rangeOfString:@"encrypted_userid"].length != 0) {
			counter = 1;
			receivedData = (NSMutableData*)[data dataUsingEncoding:NSUTF8StringEncoding];
			[self connectionDidFinishLoading:nil];
		} else {
			NSString *authCode = [GlobalMethods getStringFromRange:@"action=\"/sso/UI/Login?AMAuthCookie=" toRange:@"\"  method=\"post\">" withString:data includeRange:YES];
			NSLog(@"auth code => %@",authCode);
			NSString *postURL = [NSString stringWithFormat:@"https://login.nyu.edu/sso/UI/Login?AMAuthCookie=%@",authCode];

			NSString *postCommand = [NSString stringWithFormat:@"IDToken0=&IDToken1=%@&IDToken2=%@&IDButton=Log+In&goto="
									 "aHR0cDovL2hvbWUubnl1LmVkdTo4MC9jZ2ktYmluL2Fsb2dpbi5jZ2k/bmV0aWQ9cmMxNDIx&gotoOnFail=&SunQueryParamsString=&encoded=true&gx_charset=UTF-8",
									 netid.text,[password.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			[self connectToURL:postURL withPost:postCommand];
		}
	} else {
		// i should really FIX this
		[self.navigationController pushViewController:avc animated:YES];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
	[sender resignFirstResponder];
	
	if([GlobalMethods isNetworkAvailableWithURL:@"http://www.home.nyu.edu/"])
		[self loginToNYUHome:sender];
	else {
		[GlobalMethods display404ErrorAlert];
		[activityIndicator stopAnimating];
	}
	
	return YES;
}

- (void)connectToURL:(NSString*)url withPost:(NSString*)post {	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy 
															timeoutInterval:60];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
	
	if(!connection)
		NSLog(@"no connection, error");
	receivedData = [[NSMutableData data] retain];
	
	[request release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"error msg => %@",error);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Sorry, there was an error establishing a connection" 
												   delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[activityIndicator stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {  
    [receivedData setLength:0];
}  

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {  
    [receivedData appendData:data];  
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection { 
	self.navigationItem.rightBarButtonItem = clearItemButton;
	
	counter++;
  	NSMutableString *dataString = [[[NSMutableString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] autorelease];
	NSLog(@"data - %@",dataString);
	
	if(counter == 1) {
		if([dataString rangeOfString:@"Invalid Password"].length != 0) {
			// reset counter to reattempt login
			counter = 0;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Credentials" message:@"Sorry, your netid or password was invalid." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alert show];
			[alert release];
			loginButton.enabled = YES;
			return;
		}
		
		// login was a success
		[self connectToURL:@"http://home.nyu.edu/cgi-bin/alogin.cgi" withPost:@""];
	} else if(counter == 2) {
		NSLog(@"2nd debug");
		
		// successful login
		if ([dataString rangeOfString:@"<input type=\"hidden\" name=\""].length == 0) {
			// reset counter to reattempt login
			counter = 0;
			[GlobalMethods display404ErrorAlert];
			loginButton.enabled = YES;
			return;
		}
		NSString *stripped = [GlobalMethods getStringFromRange:@"<input type=\"hidden\" name=\"" toRange:@"</form>" withString:dataString includeRange:NO];

//		NSString *stripped = [GlobalMethods getStringFromRange:@"<input type=\"hidden\" name=\"" toRange:@"</fieldset>" withString:dataString includeRange:NO];
	//	stripped = [stripped substringToIndex:[stripped length]-12];
		NSArray *lines = [stripped componentsSeparatedByString:@"\n"];
		
		NSMutableString *postString = [NSMutableString new];
//		NSLog(@"d2 => stripped txt | %@", stripped);
		// example: <input type="hidden" name="timestamp" value="1246461468" />
		for (NSString* line in lines) {
			if([line isEqualToString:@""]) break;
//			NSLog(@"string => %@",line);
			
			// strips double quotes		// example: <input type=hidden name=timestamp value=1246461468 />
			line = [line stringByReplacingOccurrencesOfString:@"\"" withString:@""];
			
//			NSLog(@"line => %@",line);
			NSRange valueRange = [line rangeOfString:@"value="];
			NSString *stripKey = @"";
			NSString *stripValue = @"";
			
			if (valueRange.length == 0) {
				stripKey = [GlobalMethods getStringFromRange:@"name=" toRange:@" />" withString:line includeRange:YES];
//				NSLog(@"stripped key => %@",stripKey);
			} else {
				stripKey = [GlobalMethods getStringFromRange:@"name=" toRange:@"value=" withString:line includeRange:YES];
				stripValue = [GlobalMethods getStringFromRange:@"value=" toRange:@">" withString:line includeRange:YES];
				stripValue = [stripValue stringByReplacingOccurrencesOfString:@" /" withString:@""];
//				NSLog(@"%@ => %@", stripKey, stripValue);
			}
			
			stripKey = [stripKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			[postString appendString:[NSString stringWithFormat:@"%@=%@&",stripKey,stripValue]];
		}
		[postString setString:[postString stringByReplacingOccurrencesOfString:@"%" withString:@"%25"]];
		[postString setString:[postString substringToIndex:[postString length]-1]];
//		NSLog(@"poststring = %@",postString);
		
		[self connectToURL:@"https://www1.albert.nyu.edu/cgi-bin/sisexe.cgi" withPost:postString];
		
	} else if(counter == 3) {
		NSLog(@"QUESTA ERROR - The Web server is unable to connect with the source of the data that you have requested.  Please try again later.");
		// by the time the application gets here, it means albert is already loaded, time to parse out URL links
		
		// if this substring was not found, there was an error
		if([dataString rangeOfString:@"<!-- START OF ACADEMIC RECORDS -->"].length == 0) {
			[GlobalMethods display404ErrorAlert];
			counter = 0;
			loginButton.enabled = YES;
			return;
		}
		
		// parse academic records
		NSString *academicsParsedString = [GlobalMethods getStringFromRange:@"<!-- START OF ACADEMIC RECORDS -->" toRange:@"<!-- START OF REGISTRATION -->" withString:dataString includeRange:NO];
		//		NSLog(@"pulled dstring - %@", academicsParsedString);
		NSArray *academicsParsedArray = [academicsParsedString componentsSeparatedByString:@"\n"];
		
		// overall dictionary
		NSMutableDictionary *urlDictionary = [NSMutableDictionary new];
		
		// academic dictionary
		NSMutableArray *academicRecords = [NSMutableArray new];
		for(NSString *line in academicsParsedArray) {
//			NSLog(@"%@",line);
			BOOL getURL = NO;
			NSString *linkTitle;
			
			if([line rangeOfString:@"Student Schedule"].length != 0) {
				linkTitle = [[NSString alloc] initWithString:@"Student Schedule"];
				getURL = YES;
			} else if([line rangeOfString:@"Midterm Grades"].length != 0) {
				linkTitle = [[NSString alloc] initWithString:@"Midterm Grades"];
				getURL = YES;
			} else if([line rangeOfString:@"Final Grades"].length != 0) {
				linkTitle = [[NSString alloc] initWithString:@"Final Grades"];
				getURL = YES;			
			} else if([line rangeOfString:@"Unofficial Transcript"].length != 0) {
				linkTitle = [[NSString alloc] initWithString:@"Unofficial Transcript"];
				getURL = YES;
			} else if([line rangeOfString:@"Degree Progress Report"].length != 0) {
				linkTitle = [[NSString alloc] initWithString:@"Degree Progress Report"];
				getURL = YES;
			}
			
			if(getURL) {
				NSString *url = [GlobalMethods getStringFromRange:@"../cgi-bin/sisget.cgi?/" toRange:@"\" title=" withString:line includeRange:YES];
				NSString *progName;
				
				// the router code is unique for each session, this is the utilized to logout
				if(routerCode == nil) {
					progName = [url substringToIndex:[url rangeOfString:@"/"].location];
					routerCode = [url substringFromIndex:[url rangeOfString:@"/"].location+1];
					NSLog(@"what is the router code? %@",routerCode);
				}
				
				NSString *newURL = [[NSString alloc] initWithFormat:@"https://www1.albert.nyu.edu/cgi-bin/sisget.cgi?/%@",url];
				NSDictionary *tDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:linkTitle,newURL,progName,routerCode,nil] 
																	forKeys:[NSArray arrayWithObjects:@"title",@"url",@"progName",@"routerCode",nil]];
				[academicRecords addObject:tDict];
				
				// release object
				[tDict release];
				[newURL release];
				[linkTitle release];
			}
		}
		[urlDictionary setValue:academicRecords forKey:@"Academic Records"];
		[academicRecords release];
		
		// REGISTRATION
		NSString *registrationParsedString = [GlobalMethods getStringFromRange:@"<!-- START OF REGISTRATION -->" toRange:@"<!-- START OF FINANCIAL AID -->" withString:dataString includeRange:NO];
		NSArray *registrationParsedArray = [registrationParsedString componentsSeparatedByString:@"\n"];
		
		NSMutableArray *registrationRecords = [NSMutableArray new];
		for(NSString *line in registrationParsedArray) {
			BOOL getURL = NO;
			NSString *linkTitle;
			
			// FIX: convert this into a function with an array as a paramater, or a dictionary
			if([line rangeOfString:@"Registration Status"].length != 0) {
				linkTitle = [[NSString alloc] initWithString:@"Registration Status"];
				getURL = YES;
			} else if([line rangeOfString:@"Register"].length != 0) {
				linkTitle = [[NSString alloc] initWithString:@"Register"];
				getURL = YES;
			}
			
			if(getURL) {
				NSString *url = [GlobalMethods getStringFromRange:@"../cgi-bin/sisget.cgi?/" toRange:@"\" title=" withString:line includeRange:YES];
				NSString *progName = [url substringToIndex:[url rangeOfString:@"/"].location];
				
				NSString *newURL = [[NSString alloc] initWithFormat:@"https://www1.albert.nyu.edu/cgi-bin/sisget.cgi?/%@",url];
				NSDictionary *tDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:linkTitle,newURL,progName,routerCode,nil] 
																	forKeys:[NSArray arrayWithObjects:@"title",@"url",@"progName",@"routerCode",nil]];
				[registrationRecords addObject:tDict];
				
				// release object
				[tDict release];
				[newURL release];
				[linkTitle release];
			}			
		}
		[urlDictionary setValue:registrationRecords forKey:@"Registration"];
		[registrationRecords release];
		
		[self loginSuccessfulWithDictionary:urlDictionary];
		[urlDictionary release];
	}
	
	[activityIndicator stopAnimating];
} 

- (void)loginSuccessfulWithDictionary:(NSDictionary*)dictionary {
	[FlurryAPI logEvent:@"Logged into Albert"];
	 
	avc = [[AlbertViewController alloc] init];
	avc.urlDictionary = dictionary;
	loginButton.enabled = YES;
	[self.navigationController pushViewController:avc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[avc release];
	[routerCode release];
	[receivedData dealloc];
	[password dealloc];
	[netid dealloc];
	[removeKeyboardButton dealloc];
	[loginButton dealloc];
	[homeImageView dealloc];
    [super dealloc];
}

@end
