//
//  RootViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "RootViewController.h"
#import "SettingsCell.h"
#import "BrowserViewController.h"

@implementation RootViewController
@synthesize form, resultsViewController, settingsViewController, loginViewController, favoritesViewController, advancedSearchViewController;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,460)];
	contentView.backgroundColor = [UIColor clearColor];
	self.view = contentView;
	[contentView release];
	
	UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	backgroundImage.image = [UIImage imageNamed:@"background.png"];
	[self.view addSubview:backgroundImage];
	[backgroundImage release];
	
	form = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,460) style:UITableViewStyleGrouped];
	form.dataSource = self;
	form.delegate = self;
	form.scrollEnabled = NO;
	[self.view addSubview:form];

	UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(advancedSearch:)];
	self.navigationItem.rightBarButtonItem = searchButton;
	[searchButton release];
	
	UIBarButtonItem *albertButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"albert.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayAlbertLoginView:)];
	UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmarks.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayBookmarks:)];
	UIBarButtonItem *academicCalendarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"calendar.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayAcademicCalendar:)];
	UIBarButtonItem *serverStatusButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"status.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayServerStatus:)];
	UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayApplicationInfo:)];
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,376,320,44)];
	toolbar.barStyle = UIBarStyleBlackOpaque;
	[toolbar setItems:[NSArray arrayWithObjects:albertButton,flexSpace,favoritesButton,flexSpace,academicCalendarButton,flexSpace,serverStatusButton,flexSpace,infoButton,nil]];
	[self.view addSubview:toolbar];
	
	[albertButton release];
	[favoritesButton release];
	[academicCalendarButton release];
	[serverStatusButton release];
	[infoButton release];
	[flexSpace release];
	[toolbar release];
}

- (void)viewDidLoad {
    [super viewDidLoad];	
	self.title = @"NYU Courses";
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	// top padding
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,30)];
	form.tableHeaderView = headerView;
	form.backgroundColor = [UIColor clearColor];
	[headerView release];
}

- (void)viewDidAppear:(BOOL)animated {
	if(settingsViewController == nil) {
		settingsViewController = [[SettingsViewController alloc] init];
		[settingsViewController initDefaultVars];
		[settingsViewController initDefaultArrays];
	}
	
	if(resultsViewController == nil)
		resultsViewController = [[FormViewController alloc] init]; 
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if([prefs boolForKey:@"changed"]) {
		[prefs setBool:NO forKey:@"changed"];
		
		DLog(@"changed? => %@, %d", resultsViewController, [resultsViewController retainCount]);
//		[resultsViewController release];
		resultsViewController = nil;
		resultsViewController = [[FormViewController alloc] init]; 
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[form reloadData];
}

#pragma mark -
- (void)advancedSearch:(id)sender {
	if(advancedSearchViewController == nil)
		advancedSearchViewController = [[AdvancedSearchViewController alloc] init];
	[self.navigationController pushViewController:advancedSearchViewController animated:YES];	
}

- (void)displayAlbertLoginView:(id)sender {
	[FlurryAPI logEvent:@"Albert Login"];
//	BrowserViewController *bwc = [[BrowserViewController alloc] init];
//	bwc.scalePages = YES;
//	bwc.url = @"https://login.nyu.edu/sso/UI/Login?goto=http%3A%2F%2Fhome.nyu.edu%3A80%2Fcgi-bin%2Falogin.cgi";
//	[self.navigationController pushViewController:bwc animated:YES];

	loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:loginViewController animated:YES];
}

- (void)displayBookmarks:(id)sender {
	[FlurryAPI logEvent:@"Favorites"];
	favoritesViewController = [[FavoritesViewController alloc] init];
	[self.navigationController pushViewController:favoritesViewController animated:YES];
}

- (void)displayAcademicCalendar:(id)sender {
	[FlurryAPI logEvent:@"Academic Calendar"];
	
	BrowserViewController *browser = [[BrowserViewController alloc] init];
	browser.url = @"http://rickyc.us/iphone/nyu/courses/academic_calendar.php";
	browser.scalePages = YES;
	[self.navigationController pushViewController:browser animated:YES];
	[browser release];
}

- (void)displayServerStatus:(id)sender {
	[FlurryAPI logEvent:@"Server Status"];

	BrowserViewController *browser = [[BrowserViewController alloc] init];
	browser.url = @"http://rickyc.us/iphone/nyu/courses/server_status.php";
	[self.navigationController pushViewController:browser animated:YES];
	[browser release];
}

- (void)displayApplicationInfo:(id)sender {
	[FlurryAPI logEvent:@"Application Info"];
	NSString *messageStr = @"This is not an official application by New York University. If you have any questions, comments or feedback please email me at rickyc.dev@gmail.com";
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *alertMsg = [NSString stringWithFormat:@"NYU Courses Pro v%@",version]; 
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertMsg message:messageStr delegate:self cancelButtonTitle:@"Email" otherButtonTitles:@"Cancel",nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 0)
		[self launchEmailComposer];
}

#pragma mark email
- (void)launchEmailComposer {
	[FlurryAPI logEvent:@"Email Comment"];
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setToRecipients:[NSArray arrayWithObject:@"rickyc.dev@gmail.com"]];
	[picker setSubject:@"NYU Courses Pro Feedback"];	
//	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int section = indexPath.section;
	
    static NSString *CellIdentifier = @"Cell";
    
    SettingsCell *cell = (SettingsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
        cell = [[[SettingsCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    
    // Set up the cell... 
	if(section == 0)
		[cell setField:@"Course Level:" andSetting:[self.settingsViewController levelValue] andImage:[UIImage imageNamed:@"level.png"]];
	else if(section == 1)
		[cell setField:@"School:" andSetting:[self.settingsViewController schoolValue] andImage:[UIImage imageNamed:@"school.png"]];
	else if(section == 2)
		[cell setField:@"Subject:" andSetting:[self.settingsViewController subjectValue] andImage:[UIImage imageNamed:@"subject.png"]];
	else if(section == 3)
		[cell setField:@"Term:" andSetting:[self.settingsViewController currentTerm] andImage:[UIImage imageNamed:@"term.png"]];
	else if(section == 4) {
		static NSString *NCellIdentifier = @"SearchButton";
		
		UITableViewCell *nCell = [tableView dequeueReusableCellWithIdentifier:NCellIdentifier];
		if(nCell == nil)
			nCell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:NCellIdentifier] autorelease];
		nCell.textLabel.textAlignment = UITextAlignmentCenter;
		nCell.textLabel.textColor = [UIColor blackColor];
		nCell.textLabel.backgroundColor = [UIColor clearColor];
		nCell.contentView.backgroundColor = [UIColor clearColor];
		nCell.textLabel.text = @"Search";
		nCell.contentView.opaque = YES;
		nCell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainButton.png"]];
		
		return nCell;
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section != 4) {
		self.settingsViewController.currentSettingIndex = indexPath.section;
		[self.navigationController pushViewController:self.settingsViewController animated:YES];
	} else
		[self.navigationController pushViewController:resultsViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	DLog(@"memory warning - root view controller");
}

- (void)dealloc {
	[form release];
	[advancedSearchViewController release];
	[favoritesViewController release];
	[loginViewController release];
	[resultsViewController release];
	[settingsViewController release];
    [super dealloc];
}

@end
