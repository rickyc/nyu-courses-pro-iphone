//
//  AlbertViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/10/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "AlbertViewController.h"
#import "SectionHeaderView.h"

@implementation AlbertViewController
@synthesize albertTableView, urlDictionary, browserViewController;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	albertTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	albertTableView.dataSource = self;
	albertTableView.delegate = self;
	albertTableView.sectionHeaderHeight = 18;
	albertTableView.scrollEnabled = NO;
	[self.view addSubview:albertTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [urlDictionary count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger) section {
	SectionHeaderView *sectionHeaderView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0,0,320,18)];
	NSString *title = [[[urlDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:section];
	[sectionHeaderView setTitleLabel:title];
	
	return [sectionHeaderView autorelease];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *key = [[[urlDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:section];
	
	// TEMPORARY - DELETE
	if(section == 1) return 4;
	
	return [[urlDictionary objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
	UIColor *backgroundColor = even ? [UIColor colorWithRed:0.91 green:0.91 blue:0.975 alpha:1] : [UIColor colorWithRed:0.839 green:0.839 blue:0.949 alpha:1];
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    
	cell.contentView.backgroundColor = backgroundColor;
	even = !even;
	
	// TEMPORARY - DELETE
	if (indexPath.section == 1 && indexPath.row >= 2) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}

    // Set up the cell
	NSString *key = [[[urlDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.section];
	NSDictionary *linksDict = [[urlDictionary objectForKey:key] objectAtIndex:indexPath.row];
	
	UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(44,10,260,22)];
	textLabel.text = [linksDict objectForKey:@"title"];
	textLabel.font = [UIFont boldSystemFontOfSize:20];
	textLabel.backgroundColor = backgroundColor;
	[cell addSubview:textLabel];
	[textLabel release];
	
	NSString *imageSRC = [[[linksDict objectForKey:@"title"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]; 
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imageSRC]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	// TEMPORARY - DELETE
	if (indexPath.section == 1 && indexPath.row >= 2)
		return;
	
	NSString *key = [[[urlDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.section];
	NSDictionary *linksDict = [[urlDictionary objectForKey:key] objectAtIndex:indexPath.row];
	
	if (browserViewController == nil) 
		browserViewController = [[AlbertBrowserViewController alloc] initWithNibName:@"BrowserView" bundle:[NSBundle mainBundle]];
	browserViewController.scalePages = YES;
	
	NSString *selectedOption = [linksDict objectForKey:@"title"];
	if ([selectedOption isEqualToString:@"Unofficial Transcript"]) {
		browserViewController.postData = [[NSString alloc] initWithFormat:@"progname=rws184&routercode=%@&frames=0&opt1=U&opt2=1&opt3=W&mgmtctl=R3&au=UG&career=++",
										  [linksDict objectForKey:@"routerCode"]];
		browserViewController.url = @"https://www1.albert.nyu.edu/cgi-bin/sisexe.cgi";
	} else if([selectedOption isEqualToString:@"Degree Progress Report"]) {
		browserViewController.url = @"https://www1.albert.nyu.edu/cgi-bin/sisexe.cgi";
		browserViewController.postData = [[NSString alloc] initWithFormat:@"au=UG&type=A&progname=dwb100&routercode=%@&frames=0&doubledeg=N&plansw=Y&opt1=Y&opt4=Y"
										  "&opt5=Y&opt6=N&opt9=R&mgmtctl=D1&program=P&screensec=6N1",[linksDict objectForKey:@"routerCode"]];	
	} else
		browserViewController.url = [linksDict objectForKey:@"url"];
	
	[self.navigationController pushViewController:browserViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidAppear:(BOOL)animated {
	[browserViewController release];
	browserViewController = nil;
}

- (void)dealloc {
	[browserViewController release];
	[urlDictionary release];
	[albertTableView release];
    [super dealloc];
}


@end
