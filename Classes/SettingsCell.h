//
//  SettingsCell.h
//  NYU Courses Pro
//
//  Created by Ricky Cheng on 4/8/09.
//  Copyright 2009 Family. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCell : UITableViewCell {
	UILabel *fieldLabel;
	UILabel *settingLabel;
	UIImageView *imageView;
}

- (void)setField:(NSString *)field andSetting:(NSString *)setting andImage:(UIImage*)image;

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@property(nonatomic, retain) UILabel *fieldLabel;
@property(nonatomic, retain) UILabel *settingLabel;
@property (nonatomic, retain) UIImageView *imageView; 

@end
