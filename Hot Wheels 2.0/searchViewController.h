//
//  hotwheels2FirstViewController.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarWrapper.h"

@class CarWrapper;

@interface searchViewController : UIViewController
- (void)carUpdated:(CarWrapper *) carWrapper;
@end
