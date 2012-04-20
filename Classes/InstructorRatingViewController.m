//
//  InstructorRatingViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/3/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "InstructorRatingViewController.h"
#import "RatingTableViewCell.h"
#import "SectionHeaderView.h"

@implementation InstructorRatingViewController
@synthesize instructorName, courseList, instructorTableView, ratingsWebView;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	instructorTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	instructorTableView.dataSource = self;
	instructorTableView.delegate = self;
	[self.view addSubview:instructorTableView];
}

- (void)viewDidAppear:(BOOL)animated {	
	NSString *url = [NSString stringWithFormat:@"http://rickyc.us/iphone/nyu/courses/instructor_rating.php?instructor=%@",instructorName];
	NSLog(@"url => %@",[url stringByReplacingOccurrencesOfString:@" " withString:@"%20"]);
	
	[self grabRSSFeed:url];
	
	loading = NO;
	[activityIndicator stopAnimating];
	[instructorTableView reloadData];
	
	// release and nil
	[ratingsWebView release];
	ratingsWebView = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	instructorTableView.sectionHeaderHeight = 18;
	
	// Create a 'right hand button' that is a activity Indicator
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 25.0, 25.0)];
	[activityIndicator sizeToFit];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
										  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	
	// UIActivityIndicator, adds it to right navigation button
	UIBarButtonItem *navigationRightItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	navigationRightItem.target = self;
	self.navigationItem.rightBarButtonItem = navigationRightItem;
	[navigationRightItem release];
	
	[activityIndicator startAnimating];
	loading = YES;
}

#warning convert xml feed to json
- (void)grabRSSFeed:(NSString *)urlAddress {
	courseList = [[NSMutableArray alloc] init];	
	
    // Convert the supplied URL string into a usable URL object
    NSURL *url = [NSURL URLWithString:[urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
	
    // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
    // object that actually grabs and processes the RSS data
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
	
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"//course" error:nil];
	
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) {
        NSMutableDictionary *course = [[NSMutableDictionary alloc] init];
		
        // Create a counter variable as type "int"
        int counter;
		
        // Loop through the children of the current  node
        for(counter = 0; counter < [resultElement childCount]; counter++)
			[course setObject:[[resultElement childAtIndex:counter] stringValue] forKey:[[resultElement childAtIndex:counter] name]];
        
        [courseList addObject:course];
		[course release];
    }
	NSLog(@"rss entries => %@",courseList);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section {
	SectionHeaderView *sectionHeaderView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0,0,320,18)];
	[sectionHeaderView setTitleLabel:instructorName];
	
	return [sectionHeaderView autorelease];
} 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [courseList count] == 0 ? 1 : [courseList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if([courseList count] == 0) {
		static NSString *CellIdentifier = @"Cell";
		
		UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if(cell == nil)
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.text = loading ? @"Loading" : @"No results";
		return cell;
	}
    
	static NSString *RCellIdentifier = @"RatingsCell";
    
    RatingTableViewCell *cell = (RatingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:RCellIdentifier];
    if (cell == nil)
        cell = [[[RatingTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:RCellIdentifier] autorelease];
    
    // Set up the cell
	NSDictionary *course = [courseList objectAtIndex:indexPath.row];
	[cell setSubject:[course objectForKey:@"title"]];
	[cell setCourseId:[course objectForKey:@"id"]];
	[cell setSemester:[course objectForKey:@"semester"]];
	
	// reversed order to keep the alternating consistent with the previous table
	cell.even = indexPath.row%2 == 0 ? false : true;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	// can not select the row if there are no results
	if([courseList count] == 0) return;
	
	NSDictionary *course = [courseList objectAtIndex:indexPath.row];
	
	ratingsWebView = [[BrowserViewController alloc] init];
	ratingsWebView.url = [course objectForKey:@"url"];
	[self.navigationController pushViewController:ratingsWebView animated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	NSLog(@"memory warning - instructor rating");
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[instructorName release];
	[courseList release];
	[instructorTableView release];
	[ratingsWebView release];
    [super dealloc];
}

@end
