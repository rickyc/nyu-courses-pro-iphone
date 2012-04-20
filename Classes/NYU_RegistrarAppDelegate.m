//
//  NYU_RegistrarAppDelegate.m
//  NYU Registrar
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright Family 2009. All rights reserved.
//

#import "NYU_RegistrarAppDelegate.h"

@implementation NYU_RegistrarAppDelegate
@synthesize window, navigationController, rootViewController;

#pragma mark -
#pragma mark Application lifecycle
- (void)applicationDidFinishLaunching:(UIApplication *)application { 
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];	

	// clear default settings
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setBool:NO forKey:@"memoryWarning"];
    [FlurryAPI startSession:@":)"];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *writableDBPath = [GlobalMethods getFavoritesPath];
	
	// if the file does not exist, then create the file
	if (![fileManager fileExistsAtPath:writableDBPath]) {
		NSMutableDictionary *dictprevious = [NSMutableDictionary new];
		[dictprevious writeToFile:writableDBPath atomically:YES];
		[dictprevious release];
	}
	
    // Override point for customization after app launch    
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application { 

}

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSString*)getDatabasePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"asdf"];
	return path;
}

- (void)createEditableCopyOfDatabaseIfNeeded {
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
	
	NSString *writableDBPath = [self getDatabasePath];
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (success) {
		return;
	}
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"asdf"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if (!success)
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[rootViewController release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

