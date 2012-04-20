//
//  FavoritesTableViewCell.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 7/11/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "FavoritesTableViewCell.h"


@implementation FavoritesTableViewCell
@synthesize courseTitle, instructor, term, date, location, time, even;

BOOL swipedToDelete;

- (void)setCourseTitle:(NSString *)s {
	[courseTitle release];
	courseTitle = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setInstructor:(NSString *)s {
	[instructor release];
	instructor = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setTerm:(NSString *)s {
	[term release];
	term = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setDate:(NSString *)s {
	[date release];
	date = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setTime:(NSString *)s {
	[time release];
	time = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setLocation:(NSString *)s {
	[location release];
	location = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setData:(NSDictionary *)course {
	courseTitle = [course valueForKey:@"title"];
	instructor = [course valueForKey:@"instructor"];
	term = [course valueForKey:@"term"];
	date = [course valueForKey:@"days"];
	location = [course valueForKey:@"location"];
	time = [[NSString stringWithFormat:@"%@ - %@",[course valueForKey:@"stime"],[course valueForKey:@"etime"]] retain];
}

- (void)layoutSubviews {
	CGRect b = [self bounds];
	b.size.height -= 1; // leave room for the separator line
	b.size.width += 30; // allow extra width to slide for editing
	b.origin.x -= (self.editing) ? 0 : 30; // start 30px left unless editing
	[contentView setFrame:b];
	[super layoutSubviews];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
	[super willTransitionToState:state];
	
	if(state == UITableViewCellStateShowingDeleteConfirmationMask)
		swipedToDelete = YES;
}

- (void)didTransitionToState:(UITableViewCellStateMask)state { 
	[super didTransitionToState:state];
	
	[self setNeedsDisplay];
}

- (void)drawContentView:(CGRect)r {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *backgroundColor = even ? [UIColor colorWithRed:0.91 green:0.91 blue:0.975 alpha:1] : [UIColor colorWithRed:0.839 green:0.839 blue:0.949 alpha:1];
	
	if(self.selected)
		backgroundColor = [UIColor clearColor];
	
	[backgroundColor set];
	CGContextFillRect(context, r);
	
	// padding is for editting, but we won't need this
	int padding = swipedToDelete ? 0 : 30;
	int rightPadding = self.editing ? -30+padding : padding;
	int titleWidth = self.editing ? 270 : 300;
	
	[[UIColor colorWithRed:.231 green:.141 blue:.353 alpha:1] set];	// dark purple 
	[courseTitle drawInRect:CGRectMake(padding+12,8,titleWidth,14) withFont:[UIFont boldSystemFontOfSize:14] 
		lineBreakMode:UILineBreakModeTailTruncation];

	if(!swipedToDelete) {
		[[UIColor colorWithRed:.6 green:.4 blue:.2 alpha:1] set]; // dark brown
		[term drawInRect:CGRectMake(rightPadding+210,52,100,12) withFont:[UIFont boldSystemFontOfSize:12] 
		   lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	}
	
	[[UIColor colorWithRed:.165 green:.173 blue:.157 alpha:1.0] set]; // dark grey
	[instructor drawAtPoint:CGPointMake(padding+12,30) withFont:[UIFont systemFontOfSize:12]];
	
	if(!swipedToDelete) {
		[location drawInRect:CGRectMake(rightPadding+150,30,160,14) withFont:[UIFont systemFontOfSize:12] 
			   lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
	}
	
	NSString *timeDate = [[NSString alloc] initWithFormat:@"%@ - %@",date, time];
	[timeDate drawInRect:CGRectMake(padding+12,52,160,14) withFont:[UIFont systemFontOfSize:12] 
			  lineBreakMode:UILineBreakModeClip];
	[timeDate release];
	
	swipedToDelete = NO;
}

- (void)dealloc {
	[courseTitle release];
	[instructor release];
	[term release];
	[date release];
	[time release];
	[location release];
    [super dealloc];
}

@end
