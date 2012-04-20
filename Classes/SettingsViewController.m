//
//  SettingsViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController
@synthesize settingsTable, terms, levels, schools, subjects, currentSettingIndex, currentTerm, currentSchool, currentLevel, 
currentSubject, currentSelectedRow, lastIndexPath, currentTermIndex;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,460)];
	contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.view = contentView;
	[contentView release];
	
	settingsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416) style:UITableViewStyleGrouped];
	settingsTable.dataSource = self;
	settingsTable.delegate = self;
	[self.view addSubview:settingsTable];
}

-(void)initDefaultVars {
	// inits term array, separate this to its own method	
#warning fix algorithm
	//	[Global downloadAndCacheFileFromURL:@"http://dl.dropbox.com/u/1203871/badges/cards.plist" withTTPath:@"tt://card-types.plist"];

	if ([GlobalMethods isNetworkAvailableWithURL:@"http://rickyc.us"]) {
		NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://rickyc.us/iphone/nyu/courses/resources/plists/terms.plist"]];
		NSString *listFile = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];   
		terms = [[listFile propertyList] retain];
		[listFile release];
	} else {
		// algorithm might need fixing
		terms = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"terms" ofType:@"plist"]];
	}
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	// default values are stored
	if([prefs stringForKey:@"term"] == nil) {
		[prefs setObject:[terms objectAtIndex:0] forKey:@"term"];
		[prefs setObject:@"A" forKey:@"level"];
		[prefs setObject:@"A" forKey:@"school"];
		[prefs setObject:@"" forKey:@"subject"];
	}
	
	currentTerm = [prefs stringForKey:@"term"];
	currentLevel = [prefs stringForKey:@"level"];
	currentSchool = [prefs stringForKey:@"school"];
	currentSubject = [prefs stringForKey:@"subject"];
	[prefs setBool:NO forKey:@"memoryWarning"];
}

- (void)viewDidLoad {
	currentTermIndex = [terms count];
	lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
	settingsTable.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
	[settingsTable reloadData];
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setBool:YES forKey:@"changed"];
}

- (void)viewDidDisappear:(BOOL)animated {
	UITableViewCell *selectedCell = [settingsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentSelectedRow inSection:1]];
	selectedCell.accessoryType = UITableViewCellAccessoryNone;
	
	DLog(@"view disappeared");
}

/*
- (void)saveSettings {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:currentTerm forKey:@"term"];
	[prefs setObject:currentLevel forKey:@"level"];
	[prefs setObject:currentSchool forKey:@"school"];
	[prefs setObject:currentSubject forKey:@"subject"];
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];	
	[prefs setBool:YES forKey:@"memoryWarning"];
	
	DLog(@"memory warning - settings view controller");
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (currentSettingIndex) {
		case kTerms: return terms.count; break;
		case kLevels: return levels.count; break;
		case kSchools: return schools.count; break;
		case kSubjects: 
			return [[subjects objectForKey:currentSchool] count] == 0 ? 1 : [[subjects objectForKey:currentSchool] count];	
		break;
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MyNewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];    
	}
    
	NSUInteger row = [indexPath row];
	
	// sets the currently selected row
	currentSelectedRow = row;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	switch (currentSettingIndex) {
		case kTerms: 
			cell.textLabel.text = [terms objectAtIndex:row];
			if([cell.textLabel.text isEqual:currentTerm]) {
				lastIndexPath = indexPath;
				currentTermIndex = [terms count]-row;
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		break;
		case kLevels: 
			cell.textLabel.text = [[[levels allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row]; 
			if([[levels objectForKey:currentLevel] isEqual:cell.textLabel.text]) {
				lastIndexPath = indexPath;
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		break;
		case kSchools: 
			cell.textLabel.text = [[[schools allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row]; 
			if([[schools objectForKey:currentSchool] isEqual:cell.textLabel.text]) {
				lastIndexPath = indexPath;
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		break;
		case kSubjects:
			cell.textLabel.text = [[[[subjects objectForKey:currentSchool] allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:row];
			
			// sets the checkmark
			if([[[subjects objectForKey:currentSchool] objectForKey:currentSubject] isEqual:cell.textLabel.text]) {
				lastIndexPath = indexPath;
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		break;
	}
	
	[FlurryAPI logEvent:[NSString stringWithFormat:@"Settings - %@",cell.textLabel.text]];

	/*
	cell.accessoryType = (row == oldRow && lastIndexPath != nil) ? 
	UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	*/
	
	//[levels objectForKey: [[levels allKeys] objectAtIndex:indexPath.row]];
	//	return [[courses objectForKey:[[[courses allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:section]] count];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int newRow = [indexPath row];
	int oldRow = [lastIndexPath row];
	
	if (newRow != oldRow) {
		UITableViewCell *newCell = [settingsTable cellForRowAtIndexPath:indexPath];
		newCell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		UITableViewCell *oldCell = [settingsTable cellForRowAtIndexPath: lastIndexPath]; 
		oldCell.accessoryType = UITableViewCellAccessoryNone;
		
		lastIndexPath = [indexPath retain];	
	}
	
	[settingsTable deselectRowAtIndexPath:indexPath animated:YES];
	
	NSArray *allKeys;
	NSMutableDictionary *subjectArray;
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	// Cell Selected
	switch (currentSettingIndex) {
		case kTerms:
			currentTerm = [terms objectAtIndex:indexPath.row];
			[prefs setObject:currentTerm forKey:@"term"];
		break;
		case kLevels:
			allKeys = [[levels allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			NSString *tLevel = [[[levels allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row];
			for (int i=0;i<allKeys.count;i++)
				if ([[levels objectForKey:[allKeys objectAtIndex:i]] isEqual:tLevel])
					currentLevel = [allKeys objectAtIndex:i];
			[prefs setObject:currentLevel forKey:@"level"];
		break;
		case kSchools:
			allKeys = [[schools allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			NSString *tSchool = [[[schools allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row];
			for (int i=0;i<allKeys.count;i++)
				if ([[schools objectForKey:[allKeys objectAtIndex:i]] isEqual:tSchool])
					currentSchool = [allKeys objectAtIndex:i];
			currentSubject = @"";
			[prefs setObject:currentSchool forKey:@"school"];
			[prefs setObject:currentSubject forKey:@"subject"];
		break;
		case kSubjects:
			subjectArray = [subjects objectForKey:currentSchool];
			
			allKeys = [[subjectArray allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			NSString *tSubject= [[[subjectArray allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row];
			for (int i=0;i<allKeys.count;i++)
				if ([[subjectArray objectForKey:[allKeys objectAtIndex:i]] isEqual:tSubject])
					currentSubject = [allKeys objectAtIndex:i];
			[prefs setObject:currentSubject forKey:@"subject"];
		break;
	}
}

- (NSString*)levelValue {
	return [levels objectForKey:currentLevel];
}

- (NSString*)schoolValue {
	return [schools objectForKey:currentSchool];
}

- (NSString*)subjectValue {
	return [[subjects objectForKey:currentSchool] objectForKey:currentSubject];
}

- (void)createDefaultPlists:(NSString*)name {
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",name];
	if (![GlobalMethods doesFileExist:plistName]) {
		NSString *path = [GlobalMethods getPathByPathComponent:plistName];
		NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"plist"]];
		[dict writeToFile:path atomically:YES];
	}
}

- (void)initDefaultArrays {
	[self createDefaultPlists:@"levels"];
	[self createDefaultPlists:@"schools"];
	[self createDefaultPlists:@"subjects"];
	[self createDefaultPlists:@"terms"];

	levels = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levels" ofType:@"plist"]];
	schools = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"schools" ofType:@"plist"]];
	subjects = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"subjects" ofType:@"plist"]];		
}

- (void)dealloc {
	[settingsTable release];
	[terms release];
	[levels release];
	[schools release];
	[subjects release];
	[currentTerm release];
	[currentSchool release];
	[currentLevel release];
	[currentSubject release];
	[lastIndexPath release];
    [super dealloc];
}
@end
