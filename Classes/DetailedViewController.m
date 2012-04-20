//
//  DetailedViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/8/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "DetailedViewController.h"
#import "NYU_RegistrarAppDelegate.h"
#import "BrowserViewController.h"
#import "SternInstructorRatingViewController.h"

@implementation DetailedViewController
@synthesize courseLabel, courseNumberLabel, termLabel, statusLabel, creditLabel, activityLabel, callNumberLabel, siteButton,
locationButton, instructorButton, meetingTimesLabel, toolBar, course, activitiesDictionary, sitesDictionary, locationsDictionary,
mapViewController, instructorRatingViewController;

- (IBAction)viewInstructorRating:(id)sender {
	NSString *schoolCode = [course valueForKey:@"school"]; 
	
	// College of Arts & Science
	if([schoolCode isEqualToString:@"V"]) {
		[FlurryAPI logEvent:@"CAS Instructor Rating"];
		if(instructorRatingViewController == nil)
			instructorRatingViewController = [[InstructorRatingViewController alloc] init];
		instructorRatingViewController.instructorName = instructorButton.titleLabel.text;
		[self.navigationController pushViewController:instructorRatingViewController animated:YES];		
	} else if([schoolCode isEqualToString:@"C"]) {
		[FlurryAPI logEvent:@"Stern Instructor Rating"];
		NSString *course_id = [course valueForKey:@"course_num"];
		NSString *section = [course valueForKey:@"section"];
		
		// splits this into season + year
		NSArray *termsArray = [termLabel.text componentsSeparatedByString:@" "];
		NSMutableString *termValue = [NSMutableString stringWithString:[termsArray objectAtIndex:1]];
		NSString *s = [termsArray objectAtIndex:0];
		
		if([s isEqualToString:@"Fall"])
			[termValue appendString:@"4"];
		else if([s isEqualToString:@"Summer"])
			[termValue appendString:@"3"];
		else if([s isEqualToString:@"Spring"])
			[termValue appendString:@"2"];
		else if([s isEqualToString:@"Winter"])
			[termValue appendString:@"1"];			
		
		// attempts to login to stern evaluation server
		NSString *url = [NSString stringWithFormat:@"http://rickyc.us/iphone/nyu/courses/stern.php?course=%@&section=%@&semester=%@",course_id,section,termValue];
		
		SternInstructorRatingViewController *sternViewController = [[SternInstructorRatingViewController alloc] init];
		sternViewController.urlPath = url;
		[self.navigationController pushViewController:sternViewController animated:YES];
		[sternViewController release];
	} else {
		[FlurryAPI logEvent:@"RMP Instructor Rating"];
		
		// other professors will link to ratemyprofessor.com this website is not as good, but it will have to do
		NSString *instructor = [[course valueForKey:@"instructor"] rangeOfString:@","].length == 0 ? [course valueForKey:@"instructor"] : 
		[[course valueForKey:@"instructor"] substringToIndex:[[course valueForKey:@"instructor"] rangeOfString:@","].location];
		NSString *urlString = [NSString stringWithFormat:@"http://www.ratemyprofessors.com/SelectTeacher.jsp?the_dept=All&sid=675&orderby=TLName&letter=%@", instructor];
		
		// launch in the url browser
		BrowserViewController *browserViewController = [[BrowserViewController alloc] initWithNibName:@"BrowserView" bundle:[NSBundle mainBundle]];
		browserViewController.url = urlString;
		[self.navigationController pushViewController:browserViewController animated:YES];
		[browserViewController release];
	}	
}

- (IBAction)viewSiteLocationMap:(id)sender {
	UIButton *btn = (UIButton*)sender;
	
	if([btn isEqual:siteButton]) {
		NSDictionary *site = [sitesDictionary objectForKey:[course valueForKey:@"site"]];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",[course valueForKey:@"site"]] 
								message:[site objectForKey:@"name"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		[FlurryAPI logEvent:@"Launch Maps"];
		
		// locations are in the format SILV 406, parses out the building code only
		NSRange courseRange = [[course valueForKey:@"location"] rangeOfString:@" "];
		NSDictionary *locationDict;
		
		// if there is no location name
		if(courseRange.length != 0)
			locationDict = [locationsDictionary objectForKey:[[course valueForKey:@"location"] substringToIndex:courseRange.location]];
		else
			locationDict = [locationsDictionary objectForKey:[course valueForKey:@"location"]];
		
		NSString *locName = [locationDict objectForKey:@"name"];
		
		CLLocationCoordinate2D courseCoord;
		courseCoord.latitude = [[locationDict objectForKey:@"lat"] doubleValue];
		courseCoord.longitude = [[locationDict objectForKey:@"long"] doubleValue];
		
		if(courseCoord.latitude == 0 && courseCoord.longitude == 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",[course valueForKey:@"location"]] 
															message:locName delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alert show];
			[alert release];			
		} else {
			if(mapViewController == nil) {
				mapViewController = [[MapViewController alloc] initWithNibName:@"MapView" bundle:[NSBundle mainBundle]];
				[mapViewController addAnnotation:courseCoord andTitle:[course valueForKey:@"location"] andSubtitle:locName];
			}
			[self.navigationController pushViewController:mapViewController animated:YES];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
//	NYU_RegistrarAppDelegate *appDelegate = (NYU_RegistrarAppDelegate *)[[UIApplication sharedApplication] delegate];
//	SettingsViewController *sViewController = (SettingsViewController *)[[[[appDelegate navigationController] viewControllers] objectAtIndex:0] settingsViewController];
	
//	CourseSection *cs = self.course;
	
	callNumberLabel.text = [course valueForKey:@"call"];
	creditLabel.text = [course valueForKey:@"credits"];
	activityLabel.text = [self.activitiesDictionary objectForKey:[course valueForKey:@"activity"]];
	termLabel.text = [course valueForKey:@"term"];
	
	courseLabel.text = [course valueForKey:@"title"];
	
 	statusLabel.text = [course valueForKey:@"status"]; //cs.status;
	if([statusLabel.text isEqualToString:@"Open"])
		statusLabel.textColor = [UIColor colorWithRed:0.04 green:0.306 blue:0.0 alpha:1.0];
	else if([statusLabel.text isEqualToString:@"Canceled"] || [statusLabel.text isEqualToString:@"Closed"])
		statusLabel.textColor = [UIColor redColor];
	
	[siteButton setTitle:[course valueForKey:@"site"] forState:UIControlStateNormal];
	[siteButton setTitle:[course valueForKey:@"site"] forState:UIControlStateHighlighted];
	
//	cs.location = [cs.location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//	cs.location = [cs.location isEqual:@""] ? @"TBA" : course.location;
		
	[locationButton setTitle:[course valueForKey:@"location"] forState:UIControlStateNormal];
	[locationButton setTitle:[course valueForKey:@"location"] forState:UIControlStateHighlighted];

//	cs.instructor = [cs.instructor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//	cs.instructor = [cs.instructor isEqual:@""] || [cs.instructor isEqual:@" "] ? @"STAFF, TBA" : cs.instructor;
	
	[instructorButton setTitle:[course valueForKey:@"instructor"] forState:UIControlStateNormal];
	[instructorButton setTitle:[course valueForKey:@"instructor"] forState:UIControlStateHighlighted];

#warning clean up
	NSString *sTime = [course valueForKey:@"stime"];
	NSString *eTime = [course valueForKey:@"etime"];
	if([sTime isEqualToString:@""] && [eTime isEqualToString:@""])
		meetingTimesLabel.text = [NSString stringWithFormat:@"%@",[course valueForKey:@"days"]];
	else
		meetingTimesLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@",[course valueForKey:@"days"], sTime, eTime];
	courseNumberLabel.text = [NSString stringWithFormat:@"%@ - %@", [course valueForKey:@"course_num"], [course valueForKey:@"section"]];	
		
	// init favorite buttons
	NSString *path = [GlobalMethods getFavoritesPath];
	NSMutableDictionary *favDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	if([favDict objectForKey:callNumberLabel.text] != nil) { 
		UIBarButtonItem *favFilled = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite_filled.png"] 
																	  style:UIBarButtonItemStylePlain target:self action:@selector(unmarkAsFavorite:)];
		self.navigationItem.rightBarButtonItem = favFilled;
		[favFilled release];
	} else {
		UIBarButtonItem *favorite = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite.png"] style:UIBarButtonItemStylePlain target:self action:@selector(markAsFavorite:)];
		self.navigationItem.rightBarButtonItem = favorite;
		[favorite release];
	}
}

- (void)markAsFavorite:(id)sender {
	UIBarButtonItem *favFilled = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite_filled.png"] 
									style:UIBarButtonItemStylePlain target:self action:@selector(unmarkAsFavorite:)];
	self.navigationItem.rightBarButtonItem = favFilled;
	[favFilled release];
	
	
	NSString *path = [GlobalMethods getFavoritesPath];
	NSMutableDictionary *favDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	[favDict setObject:course forKey:callNumberLabel.text];
	[favDict writeToFile:path atomically:YES];
	[favDict release];
}

- (void)unmarkAsFavorite:(id)sender {
	UIBarButtonItem *favorite = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"favorite.png"] 
									style:UIBarButtonItemStylePlain target:self action:@selector(markAsFavorite:)];
	self.navigationItem.rightBarButtonItem = favorite;
	[favorite release];
	
	NSString *path= [GlobalMethods getFavoritesPath];
	NSMutableDictionary *favDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	[favDict removeObjectForKey:callNumberLabel.text]; 
	[favDict writeToFile:path atomically:YES];	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	activitiesDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"activities" ofType:@"plist"]];
	sitesDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sites" ofType:@"plist"]];
	locationsDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"locations" ofType:@"plist"]];
}

#warning display school
#warning no longer called launchWebView
- (IBAction)launchWebView:(id)sender {
	/*
	if([[course valueForKey:@"url"] isEqualToString:@"http://rickyc.us/iphone/nyu/courses/course_description.php?url=(null)"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sorry, there is no information available for this course." 
													   delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		BrowserViewController *courseWebView = [[BrowserViewController alloc] init];
		courseWebView.url = [NSString stringWithFormat:@"http://rickyc.us/iphone/nyu/courses/course_description.php?url=%@",[course valueForKey:@"url"]];
		[self.navigationController pushViewController:courseWebView animated:YES];
		[courseWebView release];
	}	
	*/
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:@"Choose an action:"
								  delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
								  otherButtonTitles:@"Course Description", @"Course Books", nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex {
	NSLog(@"button => %d",buttonIndex);
	if(buttonIndex == 0) {
		if([[course valueForKey:@"url"] isEqualToString:@"http://rickyc.us/iphone/nyu/courses/course_description.php?url=(null)"]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sorry, there is no information available for this course." 
														   delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
			[alert show];
			[alert release];
		} else {
#warning add yearTerm, otherwise it doesn't show correct description
			BrowserViewController *courseWebView = [[BrowserViewController alloc] init];
			courseWebView.url = [NSString stringWithFormat:@"http://rickyc.us/iphone/nyu/courses/course_description.php?url=%@",[course valueForKey:@"url"]];
			[self.navigationController pushViewController:courseWebView animated:YES];
			[courseWebView release];
		}
	} else if(buttonIndex == 1)
		[self launchBookstoreData];
}

- (IBAction)emailCourseInformation:(id)sender {
	[FlurryAPI logEvent:@"Email Course"];
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	NSString *courseTitle = [courseLabel.text capitalizedString];
	[picker setSubject:[NSString stringWithFormat:@"NYU Courses - %@",courseTitle]];
		
	// Set up recipients
	//	NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
	//	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
	//	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
		
	//	[picker setToRecipients:toRecipients];
	//	[picker setCcRecipients:ccRecipients];	
	//	[picker setBccRecipients:bccRecipients];
		
		// Attach an image to the email 
	/*
		NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
		NSData *myData = [NSData dataWithContentsOfFile:path];
		[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
		*/
	
	// pro
	//http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=324587540&mt=8
	
	// Fill out the email body text
	NSString *emailBody = [NSString stringWithFormat:@"Course Title: %@\nCourse Number: %@\nCall Number: %@\nTerm: %@,Status: %@\n" \
							"Instructor: %@\nCredits: %@\nActivity: %@\nSite: %@\nLocation: %@\nMeeting Times: %@\n\nThe following information was " \
							"sent to you by an iPhone Application called NYU Courses Pro. To download this application visit the following URL " \
							"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=324587540&mt=8", courseTitle, courseNumberLabel.text, 
							callNumberLabel.text,termLabel.text,statusLabel.text,instructorButton.titleLabel.text,creditLabel.text, 
							activityLabel.text,siteButton.titleLabel.text,locationButton.titleLabel.text,meetingTimesLabel.text];
	[picker setMessageBody:emailBody isHTML:NO];
		
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
- (void)launchBookstoreData {
	BrowserViewController *bvc = [[BrowserViewController alloc] init];
	
	NSArray *courseInfo = [[course valueForKey:@"course_num"] componentsSeparatedByString:@"."];
	bvc.postData = [NSString stringWithFormat:@"term=%@&dept=%@&course=%@&section=%@",termLabel.text,[courseInfo objectAtIndex:0],
					[courseInfo objectAtIndex:1],[course valueForKey:@"section"]];
	bvc.url = @"http://rickyc.us/iphone/nyu/courses/bookstore.php";
	[self.navigationController pushViewController:bvc animated:YES];
	[bvc release];
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
	[instructorRatingViewController release];
	[mapViewController release];
	[courseLabel release];
	[courseNumberLabel release];
	[termLabel release];
	[statusLabel release];
	[creditLabel release];
	[activityLabel release];
	[callNumberLabel release];
	[siteButton release];
	[locationButton release];
	[instructorButton release];
	[meetingTimesLabel release];
	[toolBar release];
	[course release];
	[activitiesDictionary release];
	[sitesDictionary release];
	[locationsDictionary release];
    [super dealloc];
}

@end
