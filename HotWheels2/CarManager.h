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

+ (CarManager *)getSingleton;

- (CarWrapper *)getCarWrapper:(Car *) car;

- (void)releaseCarWrapper:(CarWrapper *) carWrapper;
@end
