//
//  SettingsCell.m
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/8/09.
//  Copyright 2009 Family. All rights reserved.
//

#import "SettingsCell.h"

@implementation SettingsCell
@synthesize fieldLabel, settingLabel, imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		UIView *myContentView = self.contentView;
		self.fieldLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:16.0 bold:YES];
		[myContentView addSubview:self.fieldLabel];
		[self.fieldLabel release];
		
		self.settingLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:14.0 bold:NO];
		self.settingLabel.textAlignment = UITextAlignmentRight;
		[myContentView addSubview:self.settingLabel];
		[self.settingLabel release];
		
		UIImage *noPicImageSmall = [UIImage imageNamed:@"notes.png"];
		
		self.imageView = [[UIImageView alloc] initWithImage:noPicImageSmall];
		[myContentView addSubview:self.imageView];
		[self.imageView release];
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;		
}

- (void)setField:(NSString *)field andSetting:(NSString *)setting andImage:(UIImage*)image {
	self.fieldLabel.text = field;
	self.settingLabel.text = setting;
	self.settingLabel.textColor = [UIColor darkGrayColor];
	self.imageView.image = image;
	self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellBackground.png"]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
	// getting the cell size
    CGRect contentRect = self.contentView.bounds;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
		// get the X pixel spot
        CGFloat boundsX = contentRect.origin.x;
		
		if([fieldLabel.text isEqualToString:@"Course Level:"]) {
			self.fieldLabel.frame = CGRectMake(boundsX+50, 10, 175, 20);
			self.settingLabel.frame = CGRectMake(boundsX+175, 10, 100, 22);
		} else {
			self.fieldLabel.frame = CGRectMake(boundsX+50, 10, 125, 20); 
			self.settingLabel.frame = CGRectMake(boundsX+125, 10, 150, 22);
		}
		self.imageView.frame = CGRectMake(boundsX+10,6,30,30);
	}
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold {
	// Create and configure a label.
	UIFont *font;
    if (bold)
        font = [UIFont boldSystemFontOfSize:fontSize];
    else
        font = [UIFont systemFontOfSize:fontSize];
	
    // Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  
	// To show selection properly, however, the views need to be transparent (so that the selection color shows through).  
	// This is handled in setSelected:animated:.
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor clearColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}

- (void)dealloc {
	[imageView release];
	[settingLabel release];
	[fieldLabel release];
    [super dealloc];
}

@end
