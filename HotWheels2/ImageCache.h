//
//  ImageCache.h
//  HotWheels 2.0
//
//  Created by Mike on 12/26/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
+ (UIImage *)getImage:(NSString *) imageCacheKey
	   imageIsDetails:(bool)       imageIsDetails;

+ (void)cacheImage:(UIImage *)  image
		   withKey:(NSString *) key
	imageIsDetails:(bool)       imageIsDetails;
@end

/*typedef NS_ENUM(int, ImageCacheWeight)
{
    ImageCacheWeight_Search,
    ImageCacheWeight_Collection
};

@interface ImageCache : NSObject

@end*/
