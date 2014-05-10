//
//  CarSearchResultCell.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "CarCell.h"
#import "CarWrapper.h"
#import "CarWrapperListenerDelegate.h"
#import "CarWrapperUpdatedEvent.h"
#import "ImageBank.h"
#import "UserManager.h"


@interface CarCell () <CarWrapperListenerDelegate>
@property(nonatomic, strong) CarWrapper *carWrapper;

@property(nonatomic, strong) UILabel                 *nameLabel;
@property(nonatomic, strong) UIImageView             *iconImageView;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong) UIButton                *badgeButton;
@end


@implementation CarCell

- (id)init
{
	self = [super init];
	
	// icon image
	self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 150, 100)];
	self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
	
	
	// name label
	self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 150, 20)];
	self.nameLabel.font = [UIFont systemFontOfSize:12];
	self.nameLabel.textAlignment = NSTextAlignmentCenter;
	self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	
	
	// activity indicator
	self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(65, 50, 20, 20)];
	self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	self.activityIndicatorView.hidesWhenStopped = true;
	
	
	// badge button
	self.badgeButton = [[UIButton alloc] initWithFrame:CGRectMake(102, 0, 48, 48)];
	[self.badgeButton addTarget:self action:@selector(badgeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	
	
	// add to view
	[self addSubview:self.iconImageView];
	[self addSubview:self.nameLabel];
	[self addSubview:self.activityIndicatorView];
	//[self addSubview:self.badgeButton];
	
	return self;
}
- (id)initWithCarWrapper:(CarWrapper *) carWrapper
{
	self = [self init];
	
	self.carWrapper = carWrapper;
	[self.carWrapper registerListenerDelegate:self];
	
	[self updateUI];
	
    return self;
}

- (void)dealloc
{
	[self.carWrapper unregisterListenerDelegate:self];
}



- (void)viewed
{
	if (!self.carWrapper.car.iconImage && ![self.carWrapper getDownloadCarIconImageInProgress])
		[self.carWrapper downloadCarIconImage];
}

- (CarWrapper *)getCarWrapper
{
	return self.carWrapper;
}




- (void)updateUI
{
	self.nameLabel.text = self.carWrapper.car.name;
	
	[self.iconImageView setImage:self.carWrapper.car.iconImage];
	
	[self.badgeButton setImage:[self.carWrapper.car isOwned] ? [ImageBank getBadgeOwned] : [ImageBank getBadgeUnowned] forState:UIControlStateNormal];
	self.badgeButton.alpha = [self.carWrapper getSetCarOwnedInProgress]? 0.5f : 1.0f;
	
	if ([self.carWrapper getDownloadCarIconImageInProgress])
		[self.activityIndicatorView startAnimating];
	else
		[self.activityIndicatorView stopAnimating];
}

- (void)carWrapperUpdated:(CarWrapper *)carWrapper event:(CarWrapperUpdatedEvent)event
{
	[self updateUI];
	
	UIScrollView *superview = (UIScrollView *)self.superview;
	
	// if we downloaded the icon image, animate it in
	// but only if this cell is visible and not a custom car
	if (event == CWUE_DoneDownloadingIconImage &&
		self.frame.origin.y + self.frame.size.height > superview.contentOffset.y &&
		self.frame.origin.y < superview.contentOffset.y + superview.frame.size.height)
	{
		// only animate position if the car is not custom
		if (!self.carWrapper.car.isCustom)
		{
			CGRect originalFrame = self.iconImageView.frame;
			self.iconImageView.frame = CGRectMake(-40, -10, 150, 100);
			
			[UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionTransitionNone animations:^{
				self.iconImageView.frame = originalFrame;
			} completion:^ (BOOL finished) {
				if (finished)
					self.iconImageView.frame = originalFrame;
			}];
		}
		
		self.iconImageView.opaque = false;
		self.iconImageView.alpha = 0.0f;
		
		[UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
			self.iconImageView.alpha = 1.0;
		} completion:^ (BOOL finished) {
			if (finished)
				self.iconImageView.alpha = 1.0;
				self.iconImageView.opaque = true;
		}];
	}
}




- (IBAction)badgeButtonPressed:(id) sender
{
	if (![self.carWrapper getSetCarOwnedInProgress])
	{
		if ([self.carWrapper.car isOwned])
			[self.carWrapper setCarUnowned:[UserManager getLoggedInUserID]];
		else
			[self.carWrapper setCarOwned:[UserManager getLoggedInUserID]];
	}
}
@end