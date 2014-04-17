//
//  addCarNavigationController.m
//  HotWheels 2.0
//
//  Created by Mike on 4/15/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "addCarNavigationController.h"

@interface addCarNavigationController ()
@property(nonatomic, strong) IBOutlet UITabBarItem *addCarTabBarItem;
@end

@implementation addCarNavigationController

- (void)viewDidLoad
{
	self.addCarTabBarItem.selectedImage = [UIImage imageNamed:@"addCarSelected"];
}

@end
