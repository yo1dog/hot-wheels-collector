//
//  hotwheels2DetailsViewController.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "detailsViewController.h"
#import "CarWrapperListenerDelegate.h"
#import "CarWrapperUpdatedEvent.h"
#import "CarManager.h"
#import "HotWheels2API.h"
#import "ImageBank.h"
#import "UserManager.h"
#import "ZXingObjC.h"

@interface detailsViewController () <CarWrapperListenerDelegate>
@property(nonatomic, weak) IBOutlet UIButton *badgeButton;

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UIImageView             *imageView;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *segmentLabel;
@property(nonatomic, weak) IBOutlet UILabel *seriesLabel;
@property(nonatomic, weak) IBOutlet UILabel *makeLabel;
@property(nonatomic, weak) IBOutlet UILabel *colorLabel;
@property(nonatomic, weak) IBOutlet UILabel *styleLabel;
@property(nonatomic, weak) IBOutlet UILabel *toyNumberLabel;


@property(nonatomic, weak) IBOutlet UIView      *barcodeView;
@property(nonatomic, weak) IBOutlet UIImageView *barcodeImageView;
@property(nonatomic, weak) IBOutlet UILabel     *barcodeNumbersLabel;

@property(nonatomic, strong) ZXUPCAWriter *zxWriter;
@property(nonatomic, strong) ZXImage      *barcodeZXImage;
@property(nonatomic, strong) ZXBitMatrix  *barcodeZXResult;
@property                    CGImageRef    barcodeCGImage;
@property(nonatomic, strong) UIImage      *barcodeUIImage;

@property bool addCarRequesting;
@end



@implementation detailsViewController

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// register self as listener
	if (self.carWrapper)
	{
		self.car = self.carWrapper.car;
		[self.carWrapper registerListenerDelegate:self];
	}
	
	// setup UI
	[self setupUI];
}

- (void)viewDidLayoutSubviews
{
	self.scrollView.contentSize = CGSizeMake(320, self.car.barcodeData ? 600 : 452);
}

- (void)dealloc
{
	if (self.carWrapper)
		[self.carWrapper unregisterListenerDelegate:self];
}




- (IBAction)badgeButtonPressed:(id) sender
{
	if (!self.carWrapper)
		return;
	
	// make request
	if (![self.carWrapper getSetCarOwnedInProgress])
		[self.carWrapper setCarOwned:[UserManager getLoggedInUserID] owned:!self.carWrapper.car.owned];
}


- (IBAction)addButtonPressed:(id) sender
{
	if (self.addCarRequesting)
		return;
	
	if (self.car.name.length == 0)
	{
		[self.navigationController popToRootViewControllerAnimated:true];
		[self.addCar_InfoViewController missingName];
		return;
	}
	
	self.addCarRequesting = true;
	
	// show loading overlay
	dispatch_async(dispatch_get_main_queue(), ^
	{
		UIView *loadingView = [self showLoadingOveraly];
		
		[HotWheels2API addCustomCar:self.car completionHandler:^(HotWheels2APIError *error) {
			dispatch_async(dispatch_get_main_queue(), ^
			{
				self.addCarRequesting = false;
				[loadingView removeFromSuperview];
				
				if (error)
				{
					[[error createAlert:@"Unable to Add Car"] show];
					return;
				}
				
				[self.navigationController popToRootViewControllerAnimated:true];
				[self.addCar_InfoViewController reset];
			});
		}];
	});
}


- (UIView *)showLoadingOveraly
{
	UIView *superview = self.tabBarController.view;
	
	UIView *loadingView = [[UIView alloc] initWithFrame:superview.bounds];
	loadingView.backgroundColor = [UIColor clearColor];
	
	UIView *overlay = [[UIView alloc] initWithFrame:loadingView.bounds];
	overlay.backgroundColor = [UIColor blackColor];
	overlay.opaque = false;
	overlay.alpha = 0.5;
	
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithFrame:
											 CGRectMake(loadingView.frame.size.width  * 0.5f - 40,
														loadingView.frame.size.height * 0.5f - 40,
														80, 80)];
	activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	activityView.backgroundColor = [UIColor blackColor];
	activityView.layer.cornerRadius = 10;
	activityView.layer.masksToBounds = true;
	
	[activityView startAnimating];
	
	
	[loadingView addSubview:overlay];
	[loadingView addSubview:activityView];
	[superview addSubview:loadingView];
	
	return loadingView;
}




- (void)carWrapperUpdated:(CarWrapper *) carWrapper event:(CarWrapperUpdatedEvent)event
{
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self updateUI];
	});
}



- (void)setupUI
{
	// set the static UI elements
	self.nameLabel     .text = self.car.name;
	self.segmentLabel  .text = self.car.segment;
	self.seriesLabel   .text = self.car.series;
	self.makeLabel     .text = self.car.make;
	self.colorLabel    .text = self.car.color;
	self.styleLabel    .text = self.car.style;
	self.toyNumberLabel.text = self.car.toyNumber ?: @"";
	
	if (self.car.barcodeData)
	{
		self.barcodeNumbersLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",
										 [self.car.barcodeData substringWithRange:NSMakeRange(0,  1)],
										 [self.car.barcodeData substringWithRange:NSMakeRange(1,  5)],
										 [self.car.barcodeData substringWithRange:NSMakeRange(6,  5)],
										 [self.car.barcodeData substringWithRange:NSMakeRange(11, 1)]];
		
		
		if (!self.zxWriter)
			self.zxWriter = [[ZXUPCAWriter alloc] init];
		
		NSError *error;
		self.barcodeZXResult = [self.zxWriter encode:self.car.barcodeData
											  format:kBarcodeFormatUPCA
											   width:self.barcodeImageView.frame.size.width
											  height:self.barcodeImageView.frame.size.height
											   error:&error];
		
		if (error)
		{
			NSLog(@"Error generating barcode: %@", error);
			return;
		}
		
		self.barcodeZXImage = [ZXImage imageWithMatrix:self.barcodeZXResult];
		self.barcodeCGImage = [self.barcodeZXImage cgimage];
		self.barcodeUIImage = [UIImage imageWithCGImage:self.barcodeCGImage];
		
		[self.barcodeImageView setImage:self.barcodeUIImage];
		
		self.barcodeView.layer.borderWidth = 1;
		self.barcodeView.layer.borderColor = [UIColor blackColor].CGColor;
	}
	else
		[self.barcodeView removeFromSuperview];
	
	
	if (self.carWrapper)
		[self updateUI];
	else
	{
		self.navigationItem.title = @"Preview";
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
		
		self.imageView.image = self.car.detailImage ?: [ImageBank getCarError];
		[self.activityView stopAnimating];
	}
}

- (void)updateUI
{
	if (!self.carWrapper)
		return;
	
	// update the dynamic UI elements
	self.imageView.image     = self.carWrapper.car.detailImage;
	self.badgeButton.alpha   = [self.carWrapper getSetCarOwnedInProgress] ? 0.5f : 1.0f;
	self.badgeButton.enabled = ![self.carWrapper getSetCarOwnedInProgress];
	
	[self.badgeButton setImage:(self.carWrapper.car.owned ? [ImageBank getBadgeOwned] : [ImageBank getBadgeUnowned]) forState:UIControlStateNormal];
	
	
	// if we don't have a detail image...
	if (!self.carWrapper.car.detailImage)
	{
		// download the detail image
		[self.carWrapper downloadCarDetailImage];
		
		// show the activity indicator
		if (![self.activityView isAnimating])
			[self.activityView startAnimating];
	}
	else
	{
		// hide the activity indicator
		if ([self.activityView isAnimating])
			[self.activityView stopAnimating];
	}
}

@end
