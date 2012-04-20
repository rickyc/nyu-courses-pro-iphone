//
//  SectionHeaderView.h
//  NYU Registrar
//
//  Created by Ricky Cheng on 6/30/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawView.h"
#import "FormViewController.h"

@interface SectionHeaderView : DrawView {
	NSString *titleLabel;
	NSString *url;
	FormViewController *formViewController;
}

-(void)drawInContext:(CGContextRef)context;

@property(nonatomic, copy) NSString *titleLabel;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) FormViewController *formViewController;

@end