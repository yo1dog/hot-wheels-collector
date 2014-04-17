//
//  CarManager.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/20/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarWrapper.h"

@interface CarManager : NSObject

+ (CarWrapper *)getCarWrapper:(Car *) car;

// should only be called from CarWrapper
+ (void)releaseCarWrapper:(CarWrapper *) carWrapper;
@end
