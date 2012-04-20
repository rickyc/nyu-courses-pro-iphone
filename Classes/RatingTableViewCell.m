//
//  RatingTableViewCell.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/8/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "RatingTableViewCell.h"


@implementation RatingTableViewCell
@synthesize subject, semester, courseId, even;

- (void)setSubject:(NSString *)s {
	[subject release];
	subject = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setSemester:(NSString *)s {
	[semester release];
	semester = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setCourseId:(NSString *)s {
	[courseId release];
	courseId = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    CGRect b = [self bounds];
    b.size.height -= 1; // leave room for the separator line
    b.origin.x = 0;
    [contentView setFrame:b];
    [super layoutSubviews];
}

- (void)drawContentView:(CGRect)r {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *backgroundColor = even ? [UIColor colorWithRed:0.91 green:0.91 blue:0.975 alpha:1] : [UIColor colorWithRed:0.839 green:0.839 blue:0.949 alpha:1];
	UIColor *textColor = [UIColor blackColor];
	
	if (self.highlighted) {
		backgroundColor = [UIColor clearColor];
		textColor = [UIColor whiteColor];
	}
	
	[backgroundColor set];
	CGContextFillRect(context, r);
	
	[textColor set];
	
	[subject drawInRect:CGRectMake(10,6,220,14) withFont:[UIFont boldSystemFontOfSize:14] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft];
	[semester drawInRect:CGRectMake(230,8,80,14) withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	[courseId drawAtPoint:CGPointMake(10,25) withFont:[UIFont systemFontOfSize:12]];
}


- (void)dealloc {
    [super dealloc];
}


@end
