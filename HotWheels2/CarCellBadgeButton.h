//
//  CarCellBadgeButton.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/17/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarWrapper.h"

@interface CarCellBadgeButton : UIButton
@property (nonatomic, weak) CarWrapper *carWrapper;
@end
