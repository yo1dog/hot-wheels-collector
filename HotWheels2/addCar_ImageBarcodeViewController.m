//
//  addCar_ImageBarcodeViewController.m
//  HotWheels 2.0
//
//  Created by Mike on 2/14/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "addCar_ImageBarcodeViewController.h"
#import "barcodeScannerViewController.h"
#import "detailsViewController.h"
#import "ImageBank.h"
#import "ZXingObjC.h"

@interface addCar_ImageBarcodeViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;


@property(nonatomic, weak) IBOutlet UIImageView *pictureImageView;
@property(nonatomic, strong) UIImagePickerController *takeImagePicker;
@property(nonatomic, strong) UIImagePickerController *chooseImagePicker;


@property(nonatomic, weak) IBOutlet UIView      *barcodeView;
@property(nonatomic, weak) IBOutlet UIImageView *barcodeImageView;
@property(nonatomic, weak) IBOutlet UILabel     *barcodeNumbersLabel;

@property(nonatomic, strong) ZXUPCAWriter *zxWriter;
@property(nonatomic, strong) ZXImage      *barcodeZXImage;
@property(nonatomic, strong) ZXBitMatrix  *barcodeZXResult;
@property                    CGImageRef    barcodeCGImage;
@property(nonatomic, strong) UIImage      *barcodeUIImage;
@end

static const int CAR_CUSTOM_IMAGE_WIDTH  = 640;
static const int CAR_CUSTOM_IMAGE_HEIGHT = 440;



@implementation addCar_ImageBarcodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (self.car.detailImage != NULL)
		[self.pictureImageView setImage:self.car.detailImage];
	else
		[self.pictureImageView setImage:[ImageBank getCarError]];
	
	if (self.car.barcodeData != NULL)
		[self generateBarcode:self.car.barcodeData];
	
	self.zxWriter = [[ZXUPCAWriter alloc] init];
	
	self.pictureImageView.layer.borderWidth = 1;
	self.pictureImageView.layer.borderColor = [UIColor blackColor].CGColor;
	
	
	self.barcodeView.layer.borderWidth = 1;
	self.barcodeView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)viewDidLayoutSubviews
{
	self.scrollView.contentSize = CGSizeMake(320, 409);
}




- (IBAction)takePicture:(id)sender
{
	//[self.carPictureImageView setImage:[UIImage imageNamed:@"testDetailsCustom"]];
	//[self barcodeRead:@"123456789012"];
	
	if (!self.takeImagePicker)
	{
		self.takeImagePicker = [[UIImagePickerController alloc] init];
		[self.takeImagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
		[self.takeImagePicker setDelegate:self];
	
		UIView *pictureBox = [[UIView alloc] init];
		pictureBox.layer.borderWidth = 1;
		pictureBox.layer.borderColor = [UIColor redColor].CGColor;
		
		int imageWidth  = CAR_CUSTOM_IMAGE_WIDTH;
		int imageHeight = CAR_CUSTOM_IMAGE_HEIGHT;
		
		int viewWidth = self.takeImagePicker.view.frame.size.width;
		int viewHeight = self.takeImagePicker.view.frame.size.height;
		
		if (imageWidth - viewWidth > imageHeight - viewHeight)
		{
			int scaledHeight = viewWidth * (((float)imageHeight) / imageWidth);
			pictureBox.frame = CGRectMake(0, (viewHeight - scaledHeight) * 0.5, viewWidth, scaledHeight);
		}
		else
		{
			int scaledWidth = viewHeight * (((float)imageWidth) / imageHeight);
			pictureBox.frame = CGRectMake((viewWidth - scaledWidth) * 0.5, 0, scaledWidth, viewHeight);
		}
		
		[self.takeImagePicker.view addSubview:pictureBox];
	}
	
	[self presentViewController:self.takeImagePicker animated:true completion:nil];
}

- (IBAction)choosePicture:(id)sender
{
	if (!self.chooseImagePicker)
	{
		self.chooseImagePicker = [[UIImagePickerController alloc] init];
		[self.chooseImagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		[self.chooseImagePicker setDelegate:self];
	}
	
	[self presentViewController:self.chooseImagePicker animated:true completion:nil];
}

	
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	if (image)
	{
		self.car.detailImage = [self resizeImage:image width:CAR_CUSTOM_IMAGE_WIDTH height:CAR_CUSTOM_IMAGE_HEIGHT];
		[self.pictureImageView setImage:self.car.detailImage];
	}
	
	[self dismissViewControllerAnimated:true completion:nil];
}


- (UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height
{
	float oldRatio = ((float)image.size.width) / image.size.height;
	float newRatio = ((float)width) / height;
	
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	
	if (oldRatio < newRatio)
	{
		float scaledHeight = width / oldRatio;
		[image drawInRect:CGRectMake(0, -(scaledHeight - height) * 0.5f, width, scaledHeight)];
	}
	else
	{
		float scaledWidth = height * oldRatio;
		[image drawInRect:CGRectMake(-(scaledWidth - width) * 0.5f, 0, scaledWidth, height)];
	}
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	return newImage;
}




- (void)barcodeRead:(NSString *)barCodeString
{
	self.car.barcodeData = barCodeString;
	
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self generateBarcode:barCodeString];
	});
}

- (void)generateBarcode:(NSString *)barCodeString
{
	self.barcodeNumbersLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",
									 [barCodeString substringWithRange:NSMakeRange(0,  1)],
									 [barCodeString substringWithRange:NSMakeRange(1,  5)],
									 [barCodeString substringWithRange:NSMakeRange(6,  5)],
									 [barCodeString substringWithRange:NSMakeRange(11, 1)]];
	
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"addCar_scanBarcode"])
	{
		barcodeScannerViewController *controller = (barcodeScannerViewController *)segue.destinationViewController;
		controller.addCar_ImageBarcodeViewController = self;
	}
	else if ([segue.identifier isEqualToString:@"addCar_details"])
	{
		detailsViewController *controller = (detailsViewController *)segue.destinationViewController;
		controller.car = self.car;
		controller.addCar_InfoViewController = self.addCar_InfoViewController;
	}
}
@end
