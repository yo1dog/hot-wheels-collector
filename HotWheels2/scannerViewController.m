//
//  scannerViewController.m
//  HotWheels 2.0
//
//  Created by Mike on 2/4/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "scannerViewController.h"
#import "detailsViewController.h"
#import "HotWheels2API.h"
#import "UserManager.h"
#import "CarManager.h"

@interface scannerViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
@property(nonatomic, strong) IBOutlet UIView                  *previewView;
@property(nonatomic, strong) IBOutlet UILabel                 *statusLabel;
@property(nonatomic, strong) IBOutlet UIView                  *statusLabelBackgroundView;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;
@property(nonatomic, strong) IBOutlet UIView                  *activityViewBackgroundView;

@property(nonatomic, strong) UIView  *autoAddMessageView;
@property(nonatomic, strong) UILabel *autoAddMessageLabel;

@property(nonatomic, strong) AVCaptureSession           *captureSession;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property(nonatomic, weak) CarWrapper *qrCodeCarWrapper;

@property bool ignoreSearchOrAddResponse;
@property bool isScanning;
@property bool isSearchingOrAdding;
@property bool alertShown;
@property bool autoAdd;

@property(nonatomic, strong) NSString *lastQRCodeScanned;
@property double lastQRCodeScannedTimeInitalSeconds;
@property double lastQRCodeScannedTimeLatestSeconds;
@end



@implementation scannerViewController
const static int MIN_DELAY_BETWEEN_SAME_QR_CODE_SCAN_SECONDS = 1;
const static int MAX_DELAY_BETWEEN_SAME_QR_CODE_SCAN_SECONDS = 5;

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// activity
	self.activityViewBackgroundView.backgroundColor     = [UIColor blackColor];
	self.activityViewBackgroundView.layer.cornerRadius  = 10;
	self.activityViewBackgroundView.layer.masksToBounds = true;
	
	// status
	self.statusLabelBackgroundView.backgroundColor     = [UIColor blackColor];
	self.statusLabelBackgroundView.layer.cornerRadius  = 10;
	self.statusLabelBackgroundView.layer.masksToBounds = true;
	
	
	// auto add message
	//self.autoAddMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
	//																	 self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height + 10,
	//																	 0, 25)];
	
	self.autoAddMessageView = [[UIView alloc] init];
	self.autoAddMessageView.opaque = false;
	self.autoAddMessageView.layer.cornerRadius  = 12;
	self.autoAddMessageView.layer.masksToBounds = true;
	
	self.autoAddMessageLabel = [[UILabel alloc] init];
	self.autoAddMessageLabel.font = [UIFont systemFontOfSize:15.0f];
	self.autoAddMessageLabel.textAlignment = NSTextAlignmentRight;
	self.autoAddMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
	self.autoAddMessageLabel.numberOfLines = 0;
	
	[self.autoAddMessageView addSubview:self.autoAddMessageLabel];
	[self.view addSubview:self.autoAddMessageView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self setUILoading];
	if (self.videoPreviewLayer)
		[self.videoPreviewLayer removeFromSuperlayer];
}

- (void)viewDidAppear:(BOOL)animated
{
	// we are back, stop ignoring responses
	self.ignoreSearchOrAddResponse = false;
	
	// if the scanner has not been created, create it
	if (!self.captureSession)
	{
		[self createScanner];
		[self setUIScanning];
		self.isScanning = true;
	}
	
	// the scanner has already been created
	else
	{
		// if we are not searching/adding, and there is no alert being shown, and we are not already scanning, start scanning
		if (!self.isSearchingOrAdding && !self.alertShown && !self.isScanning)
		{
			[self.previewView.layer insertSublayer:self.videoPreviewLayer atIndex:0];
			[self setUIScanning];
			self.isScanning = true;
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	// we are leaving, ignore responses and stop scanning
	self.ignoreSearchOrAddResponse = true;
	self.isScanning = false;
}

- (void)dealloc
{
	if (self.captureSession != NULL)
		[self destroyScanner];
}




- (void)setUILoading
{
	self.statusLabel.text = @"Loading...";
	self.statusLabelBackgroundView.hidden = false;
	
	[self.activityView startAnimating];
	self.activityViewBackgroundView.hidden = false;
}


- (void)setUIScanning
{
	self.statusLabel.text = @"";
	self.statusLabelBackgroundView.hidden = true;
	
	[self.activityView stopAnimating];
	self.activityViewBackgroundView.hidden = true;
	
	if (![self.captureSession isRunning])
		[self.captureSession startRunning];
}

- (void)setUISearchingOrAdding:(bool)isAdding
{
	self.statusLabel.text = isAdding? @"Adding..." : @"Searching...";
	self.statusLabelBackgroundView.hidden = false;
	
	[self.activityView startAnimating];
	self.activityViewBackgroundView.hidden = false;
	
	if (!self.autoAdd)
		[self.captureSession stopRunning];
}

- (void)setUIAlert
{
	self.statusLabel.text = @"";
	self.statusLabelBackgroundView.hidden = true;
	
	[self.activityView stopAnimating];
	self.activityViewBackgroundView.hidden = true;
}


- (IBAction)textChanged:(UITextField *)sender
{
	[self setAutoAddMessage:sender.text];
}
- (void)setAutoAddMessage:(NSString *) message
{
	[self setAutoAddMessage:message withLevel:0];
}
- (void)setAutoAddMessage:(NSString *) message withLevel:(int) level
{
	[self.autoAddMessageView.layer removeAllAnimations];
	
	self.autoAddMessageView.alpha = 1.0f;
	self.autoAddMessageLabel.text = message;
	
	UIColor *backgroundColor;
	if (level == 0)
		backgroundColor = [UIColor colorWithRed:0.0f green:(212 / 255.0f) blue:( 8 / 255.0f) alpha:1.0f];
	else if (level == 1)
		backgroundColor = [UIColor colorWithRed:1.0f green:(242 / 255.0f) blue:0.0f          alpha:1.0f];
	else
		backgroundColor = [UIColor colorWithRed:1.0f green:( 28 / 255.0f) blue:(44 / 255.0f) alpha:1.0f];
	
	self.autoAddMessageView.backgroundColor = backgroundColor;
	
	int maxWidth = self.view.frame.size.width - 20 - 10 - 10;
	CGRect textRect = [self.autoAddMessageLabel.text boundingRectWithSize: CGSizeMake(maxWidth, CGFLOAT_MAX)
																  options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
															   attributes: @{NSFontAttributeName: self.autoAddMessageLabel.font}
																  context: nil];
	
	int width = MIN((int)textRect.size.width, maxWidth);
	int height = (int)textRect.size.height + 10;
	
	self.autoAddMessageView.frame = CGRectMake(self.view.frame.size.width - width - 30, 100, width + 20, height + 2);
	self.autoAddMessageLabel.frame = CGRectMake(10, 0, width + 1, height);
	
	
	[UIView animateWithDuration:0.5f delay:3.0f options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionTransitionNone animations:^{
		self.autoAddMessageView.alpha = 0.0f;
	} completion:nil];
}





- (void)createScanner
{
	NSError *error;
	
	// get input
	AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
	
	if (!input)
	{
		NSLog(@"Error getting the device input: %@", [error localizedDescription]);
		
		[[[UIAlertView alloc]initWithTitle: @"Unable to Scan"
								   message: @"Failed to create the QR code scanner."
								  delegate: nil
						 cancelButtonTitle: @"OK"
						 otherButtonTitles: nil, nil] show];
		
		return;
	}
	
	
	// get output
	AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
	
	// set the captureSession input and output
	self.captureSession = [[AVCaptureSession alloc] init];
	[self.captureSession addInput:input];
	[self.captureSession addOutput:captureMetadataOutput];
	
	// create a dispatch queue for the metadata delegate (called when a metadata object is found)
	dispatch_queue_t dispatchQueue;
	dispatchQueue = dispatch_queue_create("scannerMetadataObjectDelegateQueue", NULL);
	[captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
	
	// set the metadata capture types
	[captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
	
	
	// setup the video preview layer using the capture session
	self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
	
	[self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	[self.videoPreviewLayer setFrame:self.previewView.layer.bounds];
	
	[self.previewView.layer insertSublayer:self.videoPreviewLayer atIndex:0];
}


- (void)destroyScanner
{
	self.captureSession = nil;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0)
	{
		AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
		NSString *qrCodeString = [metadataObj stringValue];
		
		[self qrCodeScanned:qrCodeString];
    }
}

- (void)qrCodeScanned:(NSString *) qrCodeString
{
	// if we are not scanning, do nothing
	if (!self.isScanning)
		return;
	
	double currentTimeSeconds = CACurrentMediaTime();
	
	// check if we just scanned that code recently and it hasent been too long since we first scanned that code
	if ([qrCodeString isEqualToString:self.lastQRCodeScanned] &&
		self.lastQRCodeScannedTimeLatestSeconds > currentTimeSeconds - MIN_DELAY_BETWEEN_SAME_QR_CODE_SCAN_SECONDS &&
		self.lastQRCodeScannedTimeInitalSeconds > currentTimeSeconds - MAX_DELAY_BETWEEN_SAME_QR_CODE_SCAN_SECONDS)
	{
		// update the latests last scanned time
		self.lastQRCodeScannedTimeLatestSeconds = currentTimeSeconds;
		return;
	}
	
	self.lastQRCodeScanned = qrCodeString;
	self.lastQRCodeScannedTimeInitalSeconds = currentTimeSeconds;
	self.lastQRCodeScannedTimeLatestSeconds = currentTimeSeconds;
	
	// stop scanning and start searching/adding
	self.isScanning = false;
	self.isSearchingOrAdding = true;
	
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self setUISearchingOrAdding:self.autoAdd];
	});
	
	if (self.autoAdd)
	{
		// find the car by QRCode
		[HotWheels2API getCarFromQRCode:qrCodeString userID:[UserManager getLoggedInUserID] completionHandler:^(HotWheels2APIError *error, Car *car)
		{
			// if we got an error back, show the correct response
			if (error)
			{
				self.isSearchingOrAdding = false;
				
				NSString *message;
				
				if ([error isMemberOfClass:HotWheels2APIInvalidHTTPStatusCodeError.class])
				{
					int statusCode = (int)[(HotWheels2APIInvalidHTTPStatusCodeError *)error getResponse].statusCode;
					
					if (statusCode == 404)
						message = @"Car Not Found";
					else if (statusCode == 400)
						message = @"Invalid QR Code";
				}
				
				[self setAutoAddMessage:message ?: @"Error Adding Car" withLevel:2];
				
				[self setUIScanning];
				self.isScanning = true;
				
				return;
			}
			
			// get the wrapper for the car
			// DONT FORGOT TO CHECK FOR RELEASE WHEN YOU ARE DONE
			__weak CarWrapper *carWrapper = [CarManager getCarWrapper:car];
			
			// set the car as owned
			[carWrapper setCarOwned:[UserManager getLoggedInUserID] completionHandler:^(HotWheels2APIError *error, bool setCarOwnedInProgress, bool alreadyOwned)
			{
				self.isSearchingOrAdding = false;
				
				if (error)
					[self setAutoAddMessage:[NSString stringWithFormat:@"Error Adding %@", carWrapper.car.name] withLevel:2];
				else if (setCarOwnedInProgress)
					[self setAutoAddMessage:[carWrapper.car.name stringByAppendingString:@" Adding or Removing Already"] withLevel:1];
				else if (alreadyOwned)
					[self setAutoAddMessage:[carWrapper.car.name stringByAppendingString:@" Already Owned"] withLevel:1];
				else
					[self setAutoAddMessage:[carWrapper.car.name stringByAppendingString:@" Added"] withLevel:0];
				
				[self setUIScanning];
				self.isScanning = true;
				
				// done with wrapper
				[carWrapper checkForRelease];
			}];
		}];
	}
	else
	{
		[HotWheels2API getCarFromQRCode:qrCodeString userID:[UserManager getLoggedInUserID] completionHandler:^(HotWheels2APIError *error, Car *car)
		{
			// we are no longer searching
			self.isSearchingOrAdding = false;
			
			// if we are ignoring responses, just go back to scanning
			if (self.ignoreSearchOrAddResponse)
			{
				[self setUIScanning];
				self.isScanning = true;
				
				return;
			}
			
			// if we got an error, show an alert and wait from them to dismiss it before scanning again
			if (error)
			{
				// hide the label and the activity idicator
				[self setUIAlert];
				
				// show an alert
				UIAlertView *alertView;
				
				if ([error isMemberOfClass:HotWheels2APIInvalidHTTPStatusCodeError.class])
				{
					int statusCode = (int)[(HotWheels2APIInvalidHTTPStatusCodeError *)error getResponse].statusCode;
					
					if (statusCode == 404)
					{
						alertView = [[UIAlertView alloc]initWithTitle: @"Car Not Found"
															  message: @"We were unable to find a car from the QR code you scanned."
															 delegate: self
													cancelButtonTitle: @"OK"
													otherButtonTitles: nil, nil];
					}
					else if (statusCode == 400)
					{
						alertView = [[UIAlertView alloc]initWithTitle: @"Invalid QR Code"
															  message: @"The QR Code you scanned is not a Hot Wheels Car QR code."
															 delegate: self
													cancelButtonTitle: @"OK"
													otherButtonTitles: nil, nil];
					}
				}
				
				if (!alertView)
				{
					alertView = [error createAlert:@"Search Failed"];
					alertView.delegate = self;
				}
				
				[alertView show];
				self.alertShown = true;
				
				// don't start scanning again until they dismiss the error
				return;
			}
			
			
			// success! we got a car back! Add the car or Go to the details page and wait for them to come back before scanning again
			// get the wrapper for the car
			CarWrapper *carWrapper = [CarManager getCarWrapper:car];
			self.qrCodeCarWrapper = carWrapper;
			
			// go to details page
			[self performSegueWithIdentifier:@"scannerToDetails" sender:self];
			
			// don't start scanning again until they come back
		 }];
	}
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	self.alertShown = false;
	
	[self setUIScanning];
	self.isScanning = true;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	detailsViewController *controller = (detailsViewController *)segue.destinationViewController;
	
	// set the car wrapper
	controller.carWrapper = self.qrCodeCarWrapper;
}

- (IBAction)autoAddSwitchValueChanged:(UISwitch *)autoAddSwitch
{
	self.autoAdd = autoAddSwitch.isOn;
	
	[self setAutoAddMessage:self.autoAdd? @"Auto-Add Enabled" : @"Auto-Add Disabled" withLevel:1];
}
@end
