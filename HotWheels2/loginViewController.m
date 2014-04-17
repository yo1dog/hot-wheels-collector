//
//  loginViewController.m
//  HotWheels 2.0
//
//  Created by Mike on 4/15/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "loginViewController.h"
#import "UserManager.h"

@interface loginViewController () <UITextFieldDelegate>
@property(nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property(nonatomic, strong) IBOutlet UITextField *passwordTextField;

@property(nonatomic, strong) IBOutlet UISwitch *developerModeSwitch;
@end

@implementation loginViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[UserManager login:self.developerModeSwitch.isOn? @"2" : @"1"];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.usernameTextField)
		[self.passwordTextField becomeFirstResponder];
	
	else if (textField == self.passwordTextField)
	{
		[self.passwordTextField resignFirstResponder];
		[self performSegueWithIdentifier:@"loginToTabController" sender:self];
	}
	
	return NO;
}

@end
