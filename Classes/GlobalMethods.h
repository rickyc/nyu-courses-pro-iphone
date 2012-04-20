//
//  GlobalMethods.h
//  NYU Registrar
//
//  Created by Ricky Cheng on 7/10/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GlobalMethods : NSObject {

}

+ (void)displayNoNetworkAlert;
+ (void)display404ErrorAlert;
+ (BOOL)isNetworkAvailableWithURL:(NSString*)url;
+ (NSString*)getStringFromRange:(NSString*)s1 toRange:(NSString*)s2 withString:(NSString*)string includeRange:(BOOL)include;
+ (NSString*)getFavoritesPath;
+ (NSString*)getPathByPathComponent:(NSString*)str;
+ (NSString*)convertString:(NSString*)string fromFormat:(NSString*)fromFormat toFormat:(NSString*)toFormat;
+ (BOOL)doesFileExist:(NSString*)file;

@end