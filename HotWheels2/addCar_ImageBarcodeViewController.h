//
//  addCar_ImageBarcodeViewController.h
//  HotWheels 2.0
//
//  Created by Mike on 2/14/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Car.h"
#import "addCar_InfoViewController.h"

@interface addCar_ImageBarcodeViewController : UIViewController
@property (nonatomic, weak) Car *car;
@property(nonatomic, weak) addCar_InfoViewController *addCar_InfoViewController;

- (void)barcodeRead:(NSString *)barCodeString;
@end
