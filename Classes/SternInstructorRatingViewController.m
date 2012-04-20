//
//  SternInstructorRatingViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 9/4/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "SternInstructorRatingViewController.h"
#import "RatingTableViewCell.h"
#import "BrowserViewController.h"
#import "SectionHeaderView.h"

@implementation SternInstructorRatingViewController
@synthesize coursesTableView, courses, receivedData, urlPath;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	courses = [[NSArray alloc] init];
	
	coursesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	coursesTableView.dataSource = self;
	coursesTableView.delegate = self;
	coursesTableView.sectionHeaderHeight = 18;
	[self.view addSubview:coursesTableView];
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2,self.view.frame.size.height/2,25,25)];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
										  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	[activityIndicator sizeToFit];
	
	// UIActivityIndicator, adds it to right navigation button
	activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	activityIndicatorButton.target = self;
	
	// stern login button
	sternLoginButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stern_login.png"] style:UIBarButtonItemStyleBordered target:self 
																  action:@selector(launchSternLoginView:)];
}

- (void)viewDidAppear:(BOOL)animated {
	// if stern netid and password is set then attempt to login and retrieve the list of instructors who taught the selected course
	// otherwise display an alert and display a button so the user can enter their stern login information
	if ([self shouldAttemptToLogin])
		[self retrieveRatingsData];
	else {
		NSString *message = @"In order to load the course evaluations, you will have to login to your stern account. "
								"To do this please press the icon on the upper right corner."; 
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		self.navigationItem.rightBarButtonItem = sternLoginButton;
	}
}

- (void)retrieveRatingsData {
	// if the courses array is empty then retrieve the feed for the instructors
	// otherwise display the stern settings login button
	if ([courses count] == 0) {
		self.navigationItem.rightBarButtonItem = activityIndicatorButton;
		[activityIndicator startAnimating];
		[NSThread detachNewThreadSelector:@selector(loadJSONFeed) toTarget:self withObject:nil];
	} else {
		self.navigationItem.rightBarButtonItem = sternLoginButton;
	}

}

// attempt to login if the stern netid and password are set
- (BOOL)shouldAttemptToLogin {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *netid = [prefs valueForKey:@"stern_netid"];
	NSString *password = [prefs valueForKey:@"stern_password"];
	
	if (netid == nil || password == nil) return NO;
	if ([netid isEqualToString:@""] || [password isEqualToString:@""]) return NO;
	
	return YES;
}

// create the uialertview with a username and a password field
- (void)launchSternLoginView:(id)sender {
	UIAlertView *av = [UIAlertView new];
	av.title = @"Stern Login";
	av.delegate = self;
	
	// Add Buttons
	[av addButtonWithTitle:@"Save"];
	[av addButtonWithTitle:@"Cancel"];
	
	// Make Space for Text View
	av.message = @"\n\n\n";
	
	// Adjust the frame	
	CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 130.0);
	[av setTransform:myTransform];
	
	// Have Alert View create its view heirarchy, set its frame and begin bounce animation
	[av show];
	
	// Add Text Field
	UITextField *netid = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 28.0)];
	netid.borderStyle = UITextBorderStyleRoundedRect;
	netid.placeholder = @"Netid";
	netid.clearButtonMode = UITextFieldViewModeWhileEditing;
	[av addSubview:netid];
	[netid becomeFirstResponder];
	
	UITextField *password = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 83.0, 245.0, 28.0)];
	password.secureTextEntry = YES;
	password.clearButtonMode = UITextFieldViewModeWhileEditing;
	password.placeholder = @"Password";
	password.borderStyle = UITextBorderStyleRoundedRect;
	[av addSubview:password];
	
	NSDictionary *dict = [self retrieveDefaultNetidAndPassword];
	netid.text = [dict valueForKey:@"netid"];
	password.text = [dict valueForKey:@"password"];
}

// if stern's netid is not set and the nyu home one is, then default it to the nyu home one
- (NSDictionary*)retrieveDefaultNetidAndPassword {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSString *sternNetid = [prefs objectForKey:@"stern_netid"];
	NSString *netidStr = [prefs objectForKey:@"netid"];

	if(sternNetid != nil) [dict setValue:sternNetid forKey:@"netid"];
	else if(netidStr != nil) [dict setValue:netidStr forKey:@"netid"];
	
	NSString *password = [prefs objectForKey:@"stern_password"];
	NSString *pwd = (password != nil) ? password : @"";	
	[dict setValue:pwd forKey:@"password"];
	
	return [dict autorelease];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// an alertview with one button only displays a message
	// button index 0 saves the stern login / password
	if(alertView.numberOfButtons > 1 && buttonIndex == 0) {
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		
		// loops through the uialertview and locates the uitextviews (username / password)
		for(NSObject *obj in [alertView subviews]) {
			if([obj isMemberOfClass:[UITextField class]]) {
				UITextField *tf = (UITextField*)obj;
				NSString *key = !tf.secureTextEntry ? @"stern_netid" : @"stern_password";
				[prefs setValue:tf.text forKey:key];
			}
		}
		
		// attempts to login
		[self retrieveRatingsData];
	}
}

#pragma mark -
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
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {  
    [receivedData setLength:0];
}  

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {  
    [receivedData appendData:data];  
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
 	NSMutableString *dataString = [[[NSMutableString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] autorelease];
	NSLog(@"data - %@",dataString);
}


#pragma mark -
- (NSString *)stringWithUrl:(NSURL *)url {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *netidStr = [prefs stringForKey:@"stern_netid"];
	NSString *passwordStr = [[prefs stringForKey:@"stern_password"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSString *requestString = [NSString stringWithFormat:@"username=%@&password=%@&Submit=Submit",netidStr,passwordStr];
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	NSString *postLength = [NSString stringWithFormat:@"%d", [requestData length]];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	[urlRequest setHTTPBody:requestData];
	
	// Fetch the JSON response
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	
	// Make synchronous request
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
 	// Construct a String around the Data from the response
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
}

- (id)objectWithUrl:(NSURL *)url {
	SBJSON *jsonParser = [SBJSON new];
	NSString *jsonString = [self stringWithUrl:url];
	NSLog(@"json string => %@",jsonString);
	// Parse the JSON into an Object
	return [jsonParser objectWithString:jsonString error:NULL];
}

- (void)loadJSONFeed {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSDictionary *feed = (NSDictionary*)[self objectWithUrl:[NSURL URLWithString:urlPath]];
	courses = [[[feed objectForKey:@"courses"] objectForKey:@"course"] retain];
	
	if(courses == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failure" message:@"Sorry, there was an issue logging in. Make sure your netid / password is correct and that you are currently enrolled as a Stern student."
													   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	NSLog(@"courses => %@",courses);
	[coursesTableView reloadData];
	[activityIndicator stopAnimating];
	self.navigationItem.rightBarButtonItem = sternLoginButton;

	[pool release];
}

#pragma mark Table view methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section {
	if([courses count] == 0) return nil;
	
	SectionHeaderView *sectionHeaderView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0,0,320,18)];
	[sectionHeaderView setTitleLabel:[[courses objectAtIndex:0] valueForKey:@"title"]];
	
	return [sectionHeaderView autorelease];
} 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [courses count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    	
    RatingTableViewCell *cell = (RatingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RatingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSDictionary *course = [courses objectAtIndex:indexPath.row];
	NSLog(@"dict ? => %@",course);
	[cell setSubject:[course valueForKey:@"instructor"]];
	[cell setSemester:[NSString stringWithFormat:@"%@ %@",[course valueForKey:@"semester"],[course valueForKey:@"year"]]];
	[cell setCourseId:[course valueForKey:@"course"]];
	
	cell.even = indexPath.row%2 == 0 ? false : true;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// retrieves course
	NSDictionary *course = [courses objectAtIndex:indexPath.row];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *netidStr = [prefs stringForKey:@"stern_netid"];
	NSString *passwordStr = [[prefs stringForKey:@"stern_password"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	if([netidStr isEqualToString:@""] || [passwordStr isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please login and try again" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		// start browser 
		BrowserViewController *browserViewController = [[BrowserViewController alloc] initWithNibName:@"BrowserView" bundle:[NSBundle mainBundle]];
		browserViewController.url = [NSString stringWithFormat:@"http://rickyc.us/iphone/nyu/courses/stern_eval.php?id=%@",[course valueForKey:@"id"]];
		browserViewController.postData = [NSString stringWithFormat:@"username=%@&password=%@&Submit=Submit",netidStr,passwordStr];
		[self.navigationController pushViewController:browserViewController animated:YES];
		[browserViewController release];
	}
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[activityIndicator release];
	[urlPath release];
	[receivedData release];
	[courses release];
	[coursesTableView release];
    [super dealloc];
}

@end
