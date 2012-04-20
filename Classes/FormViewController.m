//
//  FormViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "FormViewController.h"
#import "SectionCell.h"
#import "NYU_RegistrarAppDelegate.h"
#import "SectionHeaderView.h"

@implementation FormViewController
@synthesize activityIndicator, coursesTableView, searchBar, searchDisplayController, receivedData, registrarParser, courses, filteredCourses,
oldQuery, detailedViewController, navigationRightItem, hideShowInstructorButton, filterMode;

BOOL paginationParse, parseComplete, showAlertBool, courseDescriptionBool;
BOOL xmlCompletedLoaded;

// total number of entries
BOOL even;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	coursesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	coursesTableView.dataSource = self;
	coursesTableView.delegate = self;
	coursesTableView.hidden = YES;
	[self.view addSubview:coursesTableView];

	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [searchBar sizeToFit];
	searchBar.tintColor = [UIColor colorWithRed:.231 green:.141 blue:.353 alpha:1.0];
    searchBar.delegate = self;
    self.coursesTableView.tableHeaderView = searchBar;
	
	searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchDisplayController.delegate = self;
	searchDisplayController.searchResultsDataSource = self;
	searchDisplayController.searchResultsDelegate = self;
	
	// Create a 'right hand button' that is a activity Indicator
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
	[activityIndicator sizeToFit];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
										  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	
	// UIActivityIndicator, adds it to right navigation button
	navigationRightItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	navigationRightItem.target = self;
	self.navigationItem.rightBarButtonItem = navigationRightItem;
	
	// defaults
	filterMode = NO;
	parseComplete = NO;
	xmlCompletedLoaded = NO;
	pagination = 1;
	
	// init
	courses = [NSMutableArray new];
	filteredCourses = [NSMutableArray new];
	
	[activityIndicator startAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
	// this boolean resets the show no results alert
	showAlertBool = NO;
	
	// grab course contents & reload table
	[self getCourseContents];
}

- (void)viewDidAppear:(BOOL)animated {
	BOOL network = [GlobalMethods isNetworkAvailableWithURL:@"http://google.com"];

	if(!network) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message: [NSString stringWithString:@"Sorry, a data connection is necessary."] 
													   delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[alert show];
		[alert release];		
		[self.navigationController popToRootViewControllerAnimated:YES];	
	} else {
		// if there are no results
		if(showAlertBool) 
			[self showNoDataAlert];
	}
	
	// nil out the video if there is a memory warning, this is due to the fact that detailed view normally gets released
	// every time ViewDidAppear. A memory warning would cause a double free.
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if([prefs boolForKey:@"memoryWarning"]) {
		detailedViewController = nil;
		[prefs setBool:NO forKey:@"memoryWarning"];
	}
	
	if(detailedViewController != nil) {
		[detailedViewController release];
		detailedViewController = nil;
	}
	
	// OPTIMIZE!!!
	// refresh the favorites status, should optimize this by not reloading unless there is a change
	if(!filterMode) {
		[coursesTableView reloadData];
		coursesTableView.hidden = NO;
	}
}

- (void)getCourseContents {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *term = [[prefs stringForKey:@"term"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *level = [[prefs stringForKey:@"level"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *school = [[prefs stringForKey:@"school"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *subject = [[prefs stringForKey:@"subject"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSString *searchString = [[prefs stringForKey:@"search_string"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	BOOL courseNumber = [prefs boolForKey:@"course_number"];
	BOOL courseTitle = [prefs boolForKey:@"course_title"];
	BOOL professor = [prefs boolForKey:@"professor"];
	BOOL location = [prefs boolForKey:@"location"];
	BOOL callNumber = [prefs boolForKey:@"call_number"];
	
	BOOL m = [prefs boolForKey:@"m"];
	BOOL t = [prefs boolForKey:@"t"];
	BOOL w = [prefs boolForKey:@"w"];
	BOOL r = [prefs boolForKey:@"r"];
	BOOL f = [prefs boolForKey:@"f"];
	BOOL s = [prefs boolForKey:@"s"];
	BOOL u = [prefs boolForKey:@"u"];
	
	NSString *courseStatus = [[prefs stringForKey:@"course_status"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *startTime = [[prefs stringForKey:@"start_time"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *endTime = [[prefs stringForKey:@"end_time"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	// generate post string
	NSString *post = [NSString stringWithFormat:@"level=%@&school=%@&subject=%@&term=%@&page=%d&searchQuery=%@&courseNumber=%d&"
					  "courseTitle=%d&professor=%d&location=%d&callNumber=%d&m=%d&t=%d&w=%d&r=%d&f=%d&s=%d&u=%d&courseStatus=%@&"
					  "sTime=%@&eTime=%@",
					  level,school,subject,term,pagination,searchString,courseNumber,courseTitle,professor,location,callNumber,
					  m,t,w,r,f,s,u,courseStatus,startTime,endTime];
	
	if(paginationParse || self.oldQuery == nil || ![post isEqualToString:self.oldQuery]) {
		self.navigationItem.rightBarButtonItem = navigationRightItem;
		
		even = NO;
		
		if(!paginationParse) {
			[courses release];
			courses = [[NSMutableArray alloc] init];
		}
		
		self.oldQuery = post;
		
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
		
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
		NSString *urlString = [[NSString alloc] initWithFormat:@"http://rickyc.us/iphone/nyu/courses/api.php"];
		[request setURL:[NSURL URLWithString:urlString]];
		[request setHTTPMethod:@"POST"];  
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
		[request setHTTPBody:postData];
				
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];  
		if (conn)
			receivedData = [[NSMutableData data] retain];
		else   
			NSLog(@"error");
		
		self.navigationItem.rightBarButtonItem = navigationRightItem;
		[activityIndicator startAnimating];		
		[urlString release];
		[conn release];
		
		// there are still no courses after one grab, alert and bounce
		if([courses count] == 0) {
//			[self showNoDataAlert];
		}
	} else {
		parseComplete = YES;
		if(courses.count == 0)		
			showAlertBool = YES;
	}
}

- (void)grabJSONFeed {
	SBJSON *jsonParser = [[SBJSON alloc] init];
	NSString *jsonString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	NSDictionary *dict = (NSDictionary*)[jsonParser objectWithString:jsonString error:NULL];
	if([[dict objectForKey:@"courses"] count] == 0)
		xmlCompletedLoaded = YES; 
	else
		[courses addObjectsFromArray:[dict objectForKey:@"courses"]];
	[jsonString release];
	[jsonParser release];
	
	parseComplete = YES;
	
	[activityIndicator stopAnimating];
	[coursesTableView reloadData];
	coursesTableView.hidden = NO;

	// scrolls the tableview back to the top when the user changes the parameters for the search
	if(!paginationParse)
		[coursesTableView setContentOffset:CGPointMake(0, 44) animated:NO];
	
	paginationParse = NO;
}

#pragma mark -
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response { 
    [receivedData setLength:0];  
}  

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data { 
	[receivedData appendData:data];  
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection { 
	NSMutableString *dataString = [[[NSMutableString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding] autorelease];

	[self grabJSONFeed];
	
    // release the connection, and the data object  
    [receivedData release];
}  

#pragma mark Table view methods
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 18;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSMutableArray *coursesToBeParsed = filterMode ? filteredCourses : courses;
    return [coursesToBeParsed count] == 0 ? 1 : [coursesToBeParsed count];
}

-(void)showNoDataAlert {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message: [NSString stringWithString:@"No results were found."] 
												   delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[self.navigationController popToRootViewControllerAnimated:YES];	
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
		
	NSMutableArray *coursesToBeParsed = filterMode ? filteredCourses : courses;
	if(coursesToBeParsed.count == 0) return 0;
	/*{
	 if(parseComplete)
	 [self showNoDataAlert];
	 return 0;
	 }*/
	
	NSInteger rows = [[[coursesToBeParsed objectAtIndex:section] objectForKey:@"sections"] count];
	
	return rows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	float h = [coursesTableView contentSize].height;
	float y = [coursesTableView contentOffset].y;
	
	// if the scrolling surpasses the table height, load extra entries
	if(!xmlCompletedLoaded && !paginationParse && y > h-480) {
		paginationParse = YES;
		pagination += 1;
		[self getCourseContents];
	}
	   
    NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	
	NSMutableArray *coursesToBeParsed = filterMode ? filteredCourses : courses;
	
	static NSString *CellIdentifier = @"SectionTableIdentifier";
	
	SectionCell *cell = (SectionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[[SectionCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	
	// Configure the cell.
	if(courses.count != 0) {
		NSDictionary *data = [[[coursesToBeParsed objectAtIndex:section] objectForKey:@"sections"] objectAtIndex:row];
		[cell setData:data];
		cell.even = even;
	}
	
	// alternating colors
	even = !even;
	return cell;
}

#pragma mark -
- (void)launchURL:(NSString*)url {
	if([url isEqualToString:@"http://rickyc.us/iphone/nyu/courses/course_description.php?url=(null)"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Sorry, there is no information available for this course." 
													   delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {		
		BrowserViewController *courseWebView = [[BrowserViewController alloc] init];
		courseWebView.url = [NSString stringWithFormat:@"http://rickyc.us/iphone/nyu/courses/course_description.php?url=%@",url];
		[self.navigationController pushViewController:courseWebView animated:YES];
		[courseWebView release];
	}
}

- (void)toggleInstructorLabels:(id)sender {
	NSLog(@"toggle instruc lbl");
}
							
#pragma mark -
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section {
	SectionHeaderView *sectionHeaderView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0,0,320,18)];
	NSMutableArray *coursesToBeParsed = filterMode ? filteredCourses : courses;
	if(coursesToBeParsed.count == 0) return [sectionHeaderView autorelease];

	NSDictionary *dict = [coursesToBeParsed objectAtIndex:section];
	NSString *headerLbl = [NSString stringWithFormat:@"%@ - %@",[dict valueForKey:@"course_num"],[dict valueForKey:@"title"]];
	[sectionHeaderView setTitleLabel:headerLbl];

	sectionHeaderView.url = [[coursesToBeParsed objectAtIndex:section] valueForKey:@"url"];
	sectionHeaderView.formViewController = [self retain];
		
	return [sectionHeaderView autorelease];
} 

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSMutableArray *coursesToBeParsed = filterMode ? filteredCourses : courses;
	
	NSDictionary *dict = [coursesToBeParsed objectAtIndex:indexPath.section];
	NSArray *sections = [dict objectForKey:@"sections"];
	
    // Navigation logic may go here -- for example, create and push another view controller.
	if(self.detailedViewController == nil) {
		DetailedViewController *dViewController = [[DetailedViewController alloc] initWithNibName:@"DetailedView" bundle:[NSBundle mainBundle]];
		self.detailedViewController = dViewController;
		[dViewController release];
	}
	
	NSMutableDictionary *cs = (NSMutableDictionary*)[sections objectAtIndex:indexPath.row];
	[cs setObject:[dict valueForKey:@"url"] forKey:@"url"];
	[cs setObject:[dict valueForKey:@"title"] forKey:@"title"];
	[cs setObject:[dict valueForKey:@"course_num"] forKey:@"course_num"];
	[cs setObject:[dict valueForKey:@"term"] forKey:@"term"];
	[cs setObject:[dict valueForKey:@"school"] forKey:@"school"];
	[self.detailedViewController setCourse:cs];
	[self.navigationController pushViewController:self.detailedViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	[self.searchDisplayController setActive:NO];
	
	[oldQuery release];
	oldQuery = nil;
}

#pragma mark -
#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	filterMode = YES;
	
	[filteredCourses removeAllObjects];
		
	for(NSDictionary *course in courses) {
		NSString *test = [NSString stringWithFormat:@"%@ %@",[course valueForKey:@"course_num"],[course valueForKey:@"title"]];
		NSRange result = [test rangeOfString:searchText options:(NSCaseInsensitiveSearch)];

		if(result.length > 0) {
			[filteredCourses addObject:course];
		}
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	self.filterMode = NO;
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[searchBar scopeButtonTitles] objectAtIndex:[searchBar selectedScopeButtonIndex]]];
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
	[self filterContentForSearchText:[searchBar text] scope:[[searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

#pragma mark -
- (void)dealloc {
	[activityIndicator release];
	[navigationRightItem release];
	[searchDisplayController release];
	[searchBar release];
	[coursesTableView release];
	[receivedData release];
	[registrarParser release];
	[courses release];
	[filteredCourses release];
	[oldQuery release];
	[detailedViewController release];
    [super dealloc];
}

@end
