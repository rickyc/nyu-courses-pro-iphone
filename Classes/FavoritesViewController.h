//
//  FavoritesViewController.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/11/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *favoritesTableView;
}

@property(nonatomic, retain) UITableView *favoritesTableView;

- (int)getNumberOfFavorites;

@end