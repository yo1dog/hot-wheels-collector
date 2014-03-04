//
//  barcodeScannerViewController.m
//  HotWheels 2.0
//
//  Created by Mike on 2/4/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "barcodeScannerViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface barcodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property(nonatomic, weak) IBOutlet UIView                  *previewView;
@property(nonatomic, weak) IBOutlet UILabel                 *statusLabel;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityView;

@property(nonatomic, strong) AVCaptureSession           *captureSession;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property bool isScanning;
@end



@implementation barcodeScannerViewController

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.captureSession = NULL;
	self.isScanning = false;
}

- (void)viewDidAppear:(BOOL)animated
{
	[self createScanner];
	[self setUIScanning];
	self.isScanning = true;
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
	[captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject: AVMetadataObjectTypeEAN13Code]];
	
	
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
	if (metadataObjects != nil && metadataObjects.count > 0)
	{
		AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects[0];
		NSString *barcodeString = [metadataObj stringValue];
		
		if (barcodeString.length > 12)
			barcodeString = [barcodeString substringFromIndex:(barcodeString.length - 12)];
		
		[self barCodeScanned:barcodeString];
	}
}

- (void)barCodeScanned:(NSString *) barcodeString
{
	// if we are not scanning, do nothing
	if (!self.isScanning)
		return;
	
	// stop scanning
	self.isScanning = false;
	[self.addCar_ImageBarcodeViewController barcodeRead:barcodeString];
	
	// close
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self.navigationController popToViewController:self.addCar_ImageBarcodeViewController animated:true];
	});
}

- (IBAction)cancelButtonPressed:(id) sender
{
	[self.navigationController popToRootViewControllerAnimated:true];
}

@end
