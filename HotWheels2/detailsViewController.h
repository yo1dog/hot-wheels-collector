//
//  hotwheels2DetailsViewController.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarWrapper.h"
#import "addCar_InfoViewController.h"

@interface detailsViewController : UIViewController
@property(nonatomic, strong) CarWrapper *carWrapper;
@property(nonatomic, strong) Car        *car;

@property(nonatomic, weak) addCar_InfoViewController *addCar_InfoViewController;
@end