//
//  addCar_InfoViewController.m
//  HotWheels 2.0
//
//  Created by Mike on 2/13/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "addCar_InfoViewController.h"
#import "addCar_ImageBarcodeViewController.h"
#import "Car.h"

@interface addCar_InfoViewController () <UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>
@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UITextField *nameTextField;
@property(nonatomic, weak) IBOutlet UITextField *segmentTextField;
@property(nonatomic, weak) IBOutlet UITextField *seriesTextField;
@property(nonatomic, weak) IBOutlet UITextField *makeTextField;
@property(nonatomic, weak) IBOutlet UITextField *colorTextField;
@property(nonatomic, weak) IBOutlet UITextField *styleTextField;
@property(nonatomic, weak) IBOutlet UITextField *toyNumberTextField;

@property(nonatomic, weak) IBOutlet UITextView *distinguishingNotesTextView;

@property(nonatomic, strong) Car *car;
@end



@implementation addCar_InfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification object:nil];
	
	
	self.distinguishingNotesTextView.layer.borderColor = [UIColor blackColor].CGColor;
	self.distinguishingNotesTextView.layer.borderWidth = 1;
	self.distinguishingNotesTextView.layer.cornerRadius = 5;
	
	self.car = [[Car alloc] init];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	self.scrollView.contentSize = CGSizeMake(320, 517);
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.nameTextField               resignFirstResponder];
	[self.segmentTextField            resignFirstResponder];
	[self.seriesTextField             resignFirstResponder];
	[self.makeTextField               resignFirstResponder];
	[self.colorTextField              resignFirstResponder];
	[self.styleTextField              resignFirstResponder];
	[self.toyNumberTextField          resignFirstResponder];
	[self.distinguishingNotesTextView resignFirstResponder];
	
	self.car.name                = [self.nameTextField              .text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.car.segment             = [self.segmentTextField           .text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.car.series              = [self.seriesTextField            .text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.car.make                = [self.makeTextField              .text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.car.color               = [self.colorTextField             .text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.car.style               = [self.styleTextField             .text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.car.toyNumber           = [self.toyNumberTextField         .text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.car.distinguishingNotes = [self.distinguishingNotesTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
	
	CGRect frame = self.scrollView.frame;
	
	if (willShow)
		frame.size.height = keyboard.origin.y + 50;
	else
		frame.size.height = self.view.frame.size.height;
	
	
	[UIView animateWithDuration:[[notification.userInfo valueForKey:@"UIKeyboardAnimationDurationUserInfoKey"] floatValue] animations:^
	{
		[self.scrollView setFrame:frame];
	}];
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[self.scrollView scrollRectToVisible:CGRectMake(0, self.scrollView.contentSize.height - 1, 1, 1) animated:true];
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
	
	else
		[self.distinguishingNotesTextView becomeFirstResponder];
	
	return NO;
}



- (IBAction)resetButtonPressed:(id)sender
{
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Reset"
												   message: @"Are you sure you want to start over?"
												  delegate: self
										 cancelButtonTitle: @"No"
										 otherButtonTitles: @"Yes", nil];
	
	[alert show];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
		[self reset];
}

- (void)reset
{
	self.car = [[Car alloc] init];
	
	self.nameTextField              .text = nil;
	self.segmentTextField           .text = nil;
	self.seriesTextField            .text = nil;
	self.makeTextField              .text = nil;
	self.colorTextField             .text = nil;
	self.styleTextField             .text = nil;
	self.toyNumberTextField         .text = nil;
	self.distinguishingNotesTextView.text = nil;
	
	[self.nameTextField               resignFirstResponder];
	[self.segmentTextField            resignFirstResponder];
	[self.seriesTextField             resignFirstResponder];
	[self.makeTextField               resignFirstResponder];
	[self.colorTextField              resignFirstResponder];
	[self.styleTextField              resignFirstResponder];
	[self.toyNumberTextField          resignFirstResponder];
	[self.distinguishingNotesTextView resignFirstResponder];
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	addCar_ImageBarcodeViewController *controller = (addCar_ImageBarcodeViewController *)segue.destinationViewController;
	controller.car = self.car;
}
@end
