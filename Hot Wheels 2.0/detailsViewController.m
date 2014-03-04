//
//  hotwheels2DetailsViewController.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "detailsViewController.h"

#import "HotWheels2API.h"
#import "ImageBank.h"
#import "UserManager.h"
#import "CarManager.h"
#import "ZXingObjC.h"

@interface detailsViewController ()
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

@property(nonatomic, weak) CarManager *carManager;
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
	
	// register
	if (self.carWrapper)
	{
		self.carManager = [CarManager getSingleton];
		
		switch (self.parentViewType)
		{
			case DVPV_SEARCH:
				[self.carWrapper registerSearchDetailsViewController:self];
				break;
			case DVPV_COLLECTION:
				[self.carWrapper registerCollectionDetailsViewController:self];
				break;
			case DVPV_COLLECTION_REMOVALS:
				[self.carWrapper registerCollectionRemovalsDetailsViewController:self];
				break;
			case DVPV_SCANNER:
				[self.carWrapper registerScannerDetailsViewController:self];
				break;
		}
	}
	
	// setup UI
	[self setupUI];
}

- (void)viewDidLayoutSubviews
{
	self.scrollView.contentSize = CGSizeMake(320, self.car.barcode ? 600 : 452);
}

- (void)dealloc
{
	if (self.carWrapper)
	{
		switch (self.parentViewType)
		{
			case DVPV_SEARCH:
				[self.carWrapper unregisterSearchDetailsViewController];
				break;
			case DVPV_COLLECTION:
				[self.carWrapper unregisterCollectionDetailsViewController];
				break;
			case DVPV_COLLECTION_REMOVALS:
				[self.carWrapper unregisterCollectionRemovalsDetailsViewController];
				break;
			case DVPV_SCANNER:
				[self.carWrapper unregisterScannerDetailsViewController];
				break;
		}
		
		[self.carManager checkForRemoval:self.carWrapper];
	}
}




- (IBAction)badgeButtonPressed:(id) sender
{
	// make request
	[self.carWrapper requestSetCarOwned:[UserManager getUserID] owned:!self.carWrapper.car.owned];
}
- (IBAction)addButtonPressed:(id) sender
{
	NSLog(@"+ Pressed");
}




- (void)carUpdated:(CarWrapper *) carWrapper
{
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self updateUI];
	});
}



- (void)setupUI
{
	if (self.carWrapper)
		self.car = self.carWrapper.car;
	
	// set the static UI elements
	self.nameLabel     .text = self.car.name;
	self.segmentLabel  .text = self.car.segment;
	self.seriesLabel   .text = self.car.series;
	self.makeLabel     .text = self.car.make;
	self.colorLabel    .text = self.car.color;
	self.styleLabel    .text = self.car.style;
	self.toyNumberLabel.text = self.car.toyNumber;
	
	if (self.car.barcode)
	{
		self.barcodeNumbersLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",
										 [self.car.barcode substringWithRange:NSMakeRange(0,  1)],
										 [self.car.barcode substringWithRange:NSMakeRange(1,  5)],
										 [self.car.barcode substringWithRange:NSMakeRange(6,  5)],
										 [self.car.barcode substringWithRange:NSMakeRange(11, 1)]];
		
		
		if (!self.zxWriter)
			self.zxWriter = [[ZXUPCAWriter alloc] init];
		
		NSError *error;
		self.barcodeZXResult = [self.zxWriter encode:self.car.barcode
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
	// update the dynmiac UI elements
	self.imageView.image     = self.carWrapper.car.detailImage;
	self.badgeButton.alpha   = self.carWrapper.carSetOwnedRequesting ? 0.5f : 1.0f;
	self.badgeButton.enabled = !self.carWrapper.carSetOwnedRequesting;
	
	[self.badgeButton setImage:(self.carWrapper.car.owned ? [ImageBank getBadgeOwned] : [ImageBank getBadgeUnowned]) forState:UIControlStateNormal];
	
	
	// if we don't have a detail image...
	if (self.carWrapper.car.detailImage == NULL)
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
