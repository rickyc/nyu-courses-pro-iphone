//
//  SectionCell.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/5/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "SectionCell.h"
#import "CustomCellBackgroundView.h"

@implementation SectionCell
@synthesize instructor, time, day, siteLocation, even, favorite, restricted;

- (void)setInstructor:(NSString *)s {
	[instructor release];
	instructor = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setTime:(NSString *)s {
	[time release];
	time = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setDay:(NSString *)s {
	[day release];
	day = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setSiteLocation:(NSString *)s {
	[siteLocation release];
	siteLocation = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setFavorite:(BOOL)b {
	favorite = b;
	[self setNeedsDisplay];
}

- (void)setRestricted:(BOOL)b {
	restricted = b;
	[self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
   [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setData:(NSDictionary*)course {
	if(![[course valueForKey:@"status"] isEqual:@"Open"])
		[self setInstructor:[course valueForKey:@"status"]];
	else
		[self setInstructor:[course valueForKey:@"instructor"]];
	
	//self.timeLabel.text = [course.meeting_times isEqual:@" "] ? @"*To Be Arranged*" : course.meeting_times;
	NSString *sTime = [course valueForKey:@"stime"];
	NSString *eTime = [course valueForKey:@"etime"];
	NSString *timeStr = ([sTime isEqual:@""] && [eTime isEqual:@""]) ? @"*To Be Arranged*" : [NSString stringWithFormat:@"%@ - %@",sTime,eTime];
	
	[self setTime:timeStr];
	[self setDay:[course valueForKey:@"days"]];
		
	[self setSiteLocation:[NSString stringWithFormat:@"%@ - %@",[course valueForKey:@"site"], [course valueForKey:@"location"]]];
	
	// check if marked as favorite
	NSString *path = [GlobalMethods getFavoritesPath];
	NSMutableDictionary *favDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	NSDictionary *dict = [favDict objectForKey:[course valueForKey:@"call"]];
	[self setFavorite:(dict != nil)];
	
	[self setRestricted:[[course valueForKey:@"restricted"] boolValue]];
}

- (void)layoutSubviews {
    CGRect b = [self bounds];
    b.size.height -= 1; // leave room for the separator line
    b.size.width += 30; // allow extra width to slide for editing
    b.origin.x -= (self.editing) ? 0 : 30; // start 30px left unless editing
    [contentView setFrame:b];
    [super layoutSubviews];
}

- (void)didTransitionToState:(UITableViewCellStateMask)state { }

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
	
	// padding is for editting, but we won't need this
	int padding = 30;

	if([instructor isEqualToString:@"Closed"] || [instructor isEqualToString:@"Canceled"])
		[[UIColor redColor] set];
	else
		[textColor set];

	[instructor drawAtPoint:CGPointMake(padding+10, 6) withFont:[UIFont boldSystemFontOfSize:14]];
	
	[textColor set];
	[time drawAtPoint:CGPointMake(padding+10,28) withFont:[UIFont systemFontOfSize:12]];
	[day drawInRect:CGRectMake(padding+240,10,60,14) withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	[siteLocation drawInRect:CGRectMake(padding+200,28,100,14) withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	
	if (favorite) {
		UIImage *favIcon = [UIImage imageNamed:@"course_fav.png"];
		[favIcon drawAtPoint:CGPointMake(padding+302, 19)];
	}
	
	if (restricted) {
		UIImage *restrictedIcon = [UIImage imageNamed:@"course_restricted.png"];
		[restrictedIcon drawAtPoint:CGPointMake(padding+115,28)];
	}
}

- (void)dealloc {
	[siteLocation dealloc];
	[day dealloc];
	[instructor dealloc];
	[time dealloc];
    [super dealloc];
}

@end
