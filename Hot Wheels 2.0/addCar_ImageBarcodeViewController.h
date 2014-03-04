//
//  addCar_ImageBarcodeViewController.h
//  HotWheels 2.0
//
//  Created by Mike on 2/14/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Car.h"

@interface addCar_ImageBarcodeViewController : UIViewController
@property (nonatomic, weak) Car *car;

- (void)barcodeRead:(NSString *)barCodeString;
@end
