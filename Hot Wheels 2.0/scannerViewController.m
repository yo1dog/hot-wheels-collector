//
//  scannerViewController.m
//  HotWheels 2.0
//
//  Created by Mike on 2/4/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "scannerViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "HotWheels2API.h"
#import "UserManager.h"
#import "CarManager.h"

@interface scannerViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
@property(nonatomic, weak) IBOutlet UIView                  *previewView;
@property(nonatomic, weak) IBOutlet UILabel                 *statusLabel;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

@property(nonatomic, strong) AVCaptureSession           *captureSession;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property(nonatomic, weak) CarWrapper *qrCodeCarWrapper;
@property(nonatomic, weak) CarManager *carManager;

@property bool ignoreSearchResponse;
@property bool isScanning;
@property bool isSearching;
@property bool alertShown;
@end



@implementation scannerViewController

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.carManager = [CarManager getSingleton];
	self.captureSession = NULL;
	
	self.ignoreSearchResponse = false;
	self.isScanning = false;
	self.isSearching = false;
	self.alertShown  = false;
}

- (void)viewWillAppear:(BOOL)animated
{
	// if we have already created the scanner, and we are not searching, and there is no alert being shown, and we are not already scanning, show the scanning UI
	// note that we do not actually start scanning until view did appear
	if (self.captureSession != NULL && !self.isSearching && !self.alertShown && !self.isScanning)
		[self setUIScanning];
}

- (void)viewDidAppear:(BOOL)animated
{
	// we are back, stop ignoring responses
	self.ignoreSearchResponse = false;
	
	// if the scanner has not been created, create it
	if (self.captureSession == NULL)
	{
		[self createScanner];
		[self setUIScanning];
		self.isScanning = true;
	}
	
	// the scanner has already been created
	else
	{
		// if we are not searching, and there is no alert being shown, and we are not already scanning, start scanning
		if (!self.isSearching && !self.alertShown && !self.isScanning)
			self.isScanning = true;
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	// we are leaving, ignore responses
	self.ignoreSearchResponse = true;
}

- (void)dealloc
{
	if (self.captureSession != NULL)
		[self destroyScanner];
}




- (void)setUIScanning
{
	self.statusLabel.text = @"";
	[self.activityView stopAnimating];
	
	
	[self.captureSession startRunning];
}

- (void)setUISearching
{
	self.statusLabel.text = @"Searching...";
	[self.activityView startAnimating];
	
	[self.captureSession stopRunning];
}



- (void)createScanner
{
	NSError *error;
	
	// get input
	AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
	
	if (!input)
	{
		// TODO: Show error to user
		NSLog(@"Error getting the device input: %@", [error localizedDescription]);
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
	self.captureSession = NULL;
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
	
	// stop scanning and start searching
	self.isScanning = false;
	self.isSearching = true;
	
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self setUISearching];
	});
	
	[HotWheels2API getCarFromQRCode:qrCodeString userID:[UserManager getUserID] handler:^(NSError *error, Car *car)
	{
		// we are no longer searching
		self.isSearching = false;
		
		// if we are ignoring responses, just go back to scanning
		if (self.ignoreSearchResponse)
		{
			dispatch_async(dispatch_get_main_queue(), ^
			{
				[self setUIScanning];
				self.isScanning = true;
			});
			
			return;
		}
		
		// if we got an error, show an alert and wait from them to dismiss it before scanning again
		if (error)
		{
			dispatch_async(dispatch_get_main_queue(), ^
			{
				// hide the label and the activity idicator
				self.statusLabel.text = @"";
				[self.activityView stopAnimating];
				
				// show an alert
				UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Error"
															   message: [NSString stringWithFormat:@"%@", error]
															  delegate: self
													 cancelButtonTitle: @"OK"
													 otherButtonTitles: nil, nil];
				   
				[alert show];
				self.alertShown = true;
				
				// don't start scanning again until they dismiss the error
			});
		}
		
		
		// success! we got a car back! Go to the details page and wait for them to come back before scanning again
		else
		{
			// get the wrapper for the car
			CarWrapper *carWrapper = [self.carManager getCarWrapper:car];
			self.qrCodeCarWrapper = carWrapper;
			
			// go to details page
			dispatch_async(dispatch_get_main_queue(), ^
			{
				[self performSegueWithIdentifier:@"scanner_showDetails" sender:self];
			});
			
			// don't start scanning again until they come back
		}
	 }];
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
	
	// set the new car wrapper and register
	controller.carWrapper     = self.qrCodeCarWrapper;
	controller.parentViewType = DVPV_SCANNER;
}

@end
