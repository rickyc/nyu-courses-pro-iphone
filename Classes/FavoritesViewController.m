//
//  FavoritesViewController.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/11/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "FavoritesViewController.h"
#import "FavoritesTableViewCell.h"
#import "DetailedViewController.h"

@implementation FavoritesViewController
@synthesize favoritesTableView;

BOOL lastEntry;

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	favoritesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,320,416)];
	favoritesTableView.dataSource = self;
	favoritesTableView.delegate = self;
	[self.view addSubview:favoritesTableView];
}

- (void)viewWillAppear:(BOOL)animated {
	self.navigationItem.rightBarButtonItem = [self getNumberOfFavorites] == 0 ? nil : self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
 	[favoritesTableView reloadData];
}

- (void)toggleEdit:(id)sender {
	if([self getNumberOfFavorites] == 0) return;
	[self.favoritesTableView setEditing:!self.favoritesTableView.editing animated:YES];	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *path = [GlobalMethods getFavoritesPath];
	NSMutableDictionary *favDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	int counter = [[favDict allKeys] count];

	if(lastEntry) {
		lastEntry = NO;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bookmarks" message:@"You have no courses saved." 
													   delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[self.navigationController popViewControllerAnimated:YES];
		return 0;
	}
	
	return counter == 0 ? 1 : counter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"SectionTableIdentifier";
	
	NSString *path = [GlobalMethods getFavoritesPath];
	NSMutableDictionary *favDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	if([[favDict allKeys] count] != 0) {
		NSString *key = [[[favDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row];
		NSDictionary *dict = [favDict objectForKey:key];

		FavoritesTableViewCell *cell = (FavoritesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil)
			cell = [[[FavoritesTableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		
		// Configure the cell.
		[cell setData:dict];
		cell.even = indexPath.row%2 == 0;
		
		return cell;
	} else {
		static NSString *CellIdentifier2 = @"CellIdentifier";
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil)
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier2] autorelease];
		cell.textLabel.text = @"No favorites saved";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	NSString *path = [GlobalMethods getFavoritesPath];
	NSMutableDictionary *favDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	if([[favDict allKeys] count] == 0) 
		return;
	
	NSString *key = [[[favDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row];
	NSDictionary *dict = [favDict objectForKey:key];
	
	DetailedViewController *detailedViewController = [[DetailedViewController alloc] initWithNibName:@"DetailedView" bundle:[NSBundle mainBundle]];
	[detailedViewController setCourse:dict];
	[self.navigationController pushViewController:detailedViewController animated:YES];
	[detailedViewController release];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	if([self getNumberOfFavorites] == 0) return;
	[self.favoritesTableView setEditing:!self.favoritesTableView.editing animated:YES];	
}

- (int)getNumberOfFavorites {
	NSString *path = [GlobalMethods getFavoritesPath];
	NSMutableDictionary *favDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	return [[favDict allKeys] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 75;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	int counter = [self getNumberOfFavorites];
	if(counter == 0) return;
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		if(counter == 1) lastEntry = YES;
		NSString *path = [GlobalMethods getFavoritesPath];
		NSMutableDictionary *favDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		NSString *key = [[[favDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:indexPath.row];
		[favDict removeObjectForKey:key];
		[favDict writeToFile:path atomically:YES];
	
		[favoritesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[favoritesTableView reloadData];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
