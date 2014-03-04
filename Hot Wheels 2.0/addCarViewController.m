//
//  addCar_InfoViewController.m
//  HotWheels 2.0
//
//  Created by Mike on 2/5/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "addCarViewController.h"
#import "barcodeScannerViewController.h"
#import "ZXingObjC.h"

@interface addCarViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>

@property(nonatomic, weak) IBOutlet UIImageView *carPictureImageView;

@property(nonatomic, strong) UIImagePickerController *imagePicker;


@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;


@property(nonatomic, weak) IBOutlet UIView *textFieldContainerView;
@property(nonatomic)                CGRect  textFieldContainerViewOriginalFrame;
@property(nonatomic, strong)        UIView *textFieldContainerViewOriginalSuperView;

@property(nonatomic, weak) IBOutlet UITextField *nameTextField;
@property(nonatomic, weak) IBOutlet UITextField *segmentTextField;
@property(nonatomic, weak) IBOutlet UITextField *seriesTextField;
@property(nonatomic, weak) IBOutlet UITextField *makeTextField;
@property(nonatomic, weak) IBOutlet UITextField *colorTextField;
@property(nonatomic, weak) IBOutlet UITextField *styleTextField;
@property(nonatomic, weak) IBOutlet UITextField *toyNumberTextField;


@property(nonatomic, weak) IBOutlet UIView      *barcodeView;
@property(nonatomic, weak) IBOutlet UIImageView *barcodeImageView;
@property(nonatomic, weak) IBOutlet UILabel     *barcodeNumbersLabel;

@property(nonatomic, strong) ZXUPCAWriter *zxWriter;
@property(nonatomic, strong) ZXImage      *barcodeZXImage;
@property(nonatomic, strong) ZXBitMatrix  *barcodeZXResult;
@property(nonatomic)         CGImageRef    barcodeCGImage;
@property(nonatomic, strong) UIImage      *barcodeUIImage;


@property(nonatomic, weak) IBOutlet UITextView *distinguishingNotesTextView;
@end

@implementation addCarViewController

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	
	self.imagePicker = [[UIImagePickerController alloc] init];
	//[self.imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
	[self.imagePicker setDelegate:self];
	
	
	self.textFieldContainerViewOriginalFrame     = self.textFieldContainerView.frame;
	self.textFieldContainerViewOriginalSuperView = self.textFieldContainerView.superview;
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	
	self.barcodeView.layer.borderWidth = 1;
	self.barcodeView.layer.borderColor = [UIColor blackColor].CGColor;
	self.zxWriter = [[ZXUPCAWriter alloc] init];
	
	
	self.distinguishingNotesTextView.layer.borderWidth = 1;
	self.distinguishingNotesTextView.layer.borderColor = [UIColor blackColor].CGColor;
	//self.distinguishingNotesTextView.layer.cornerRadius = 10;
}

- (void)viewDidLayoutSubviews
{
	self.scrollView.contentSize = CGSizeMake(320, 635);
}



- (IBAction)takeCarPicture:(id)sender
{
	[self.carPictureImageView setImage:[UIImage imageNamed:@"testDetailsCustom"]];
	[self barcodeRead:@"123456789012"];
	//[self presentViewController:self.imagePicker animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	[self.carPictureImageView setImage:image];
	[self dismissViewControllerAnimated:true completion:nil];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if(textField == self.nameTextField)
		[self.segmentTextField becomeFirstResponder];
	
	else if(textField == self.segmentTextField)
		[self.seriesTextField becomeFirstResponder];
	
	else if(textField == self.seriesTextField)
		[self.makeTextField becomeFirstResponder];
	
	else if(textField == self.makeTextField)
		[self.colorTextField becomeFirstResponder];
	
	else if(textField == self.colorTextField)
		[self.styleTextField becomeFirstResponder];
	
	else if(textField == self.styleTextField)
		[self.toyNumberTextField becomeFirstResponder];
	
	else if(textField == self.toyNumberTextField)
		[textField resignFirstResponder];
	
	return NO;
}


- (void)keyboardWillShow:(NSNotification *)notification
{
	[self keyboardWillToggle:notification willShow:true];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
	[self keyboardWillToggle:notification willShow:false];
}
- (void)keyboardWillToggle:(NSNotification *)notification willShow:(bool)willShow
{
	CGRect keyboard = [[notification.userInfo valueForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
	
	CGRect frame = self.textFieldContainerView.frame;
	if (willShow)
	{
		[self.textFieldContainerView removeFromSuperview];
		[self.view addSubview:self.textFieldContainerView];
		frame.origin.y = 64;
		frame.size.height = keyboard.origin.y;
	}
	else
	{
		frame.origin.y    = 0;
	}
	
	
	[UIView animateWithDuration:[[notification.userInfo valueForKey:@"UIKeyboardAnimationDurationUserInfoKey"] floatValue] animations:^
	{
		[self.textFieldContainerView setFrame:frame];
	}];
}






- (void)barcodeRead:(NSString *)barCodeString
{
	dispatch_async(dispatch_get_main_queue(), ^
	{
		NSError *error;
		self.barcodeZXResult = [self.zxWriter encode:barCodeString
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

		self.barcodeNumbersLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",
										 [barCodeString substringWithRange:NSMakeRange(0,  1)],
										 [barCodeString substringWithRange:NSMakeRange(1,  5)],
										 [barCodeString substringWithRange:NSMakeRange(6,  5)],
										 [barCodeString substringWithRange:NSMakeRange(11, 1)]];
	});
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	//barcodeScannerViewController *controller = (barcodeScannerViewController *)segue.destinationViewController;
	
	//controller.addCarViewController = self;
}





- (IBAction)addButtonPressed:(id)sender
{
}
@end