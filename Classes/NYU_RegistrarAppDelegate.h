//
//  NYU_RegistrarAppDelegate.h
//  NYU Registrar
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright Family 2009. All rights reserved.
//
#import "RootViewController.h"

@interface NYU_RegistrarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	RootViewController *rootViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@end

