//
//  ImageCache.m
//  HotWheels 2.0
//
//  Created by Mike on 12/26/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "ImageCache.h"


/*@interface CachedImage : NSObject
@property (nonatomic, strong) UIImage *image;
@property ImageCacheWeight             weight;
@property long                         order;
@end

@implementation CachedImage

- (id)init:(UIImage *)        image
	weight:(ImageCacheWeight) weight
	 order:(long)             order;
{
	self = [super init];
	
	self.image  = image;
	self.weight = weight;
	self.order  = order;
	
	return self;
}
@end


@implementation ImageCache

static int DETAILS_IMAGES_MAX_NUM_CACHED = 30;
static int DETAILS_IMAGES_REMOVAL_SIZE   = 1;

static int ICON_IMAGES_MAX_NUM_CACHED            = 300;
static int ICON_IMAGES_MIN_NUM_CACHED_SEARCH     = 100;
static int ICON_IMAGES_MIN_NUM_CACHED_COLLECTION = 100;
static int ICON_IMAGES_REMOVAL_SIZE              = 20;

static NSMutableDictionary *cachedIconImages;
static NSMutableDictionary *cachedDetailsImages;

static long cachedIconImageOrder    = 0l;
static long cachedDetailsImageOrder = 0l;

+ (void)initialize
{
	[super initialize];
	
	cachedIconImages    = [[NSMutableDictionary alloc] init];
	cachedDetailsImages = [[NSMutableDictionary alloc] init];
}

+ (void)cacheIconImage:(NSString *) key image:(UIImage *) image weight:(ImageCacheWeight) weight
{
	[cachedIconImages setValue:[[CachedImage alloc] init:image
												  weight:weight
												   order:++cachedIconImageOrder]
						forKey:key];
	
	
	if ([cachedIconImages count] > ICON_IMAGES_MAX_NUM_CACHED)
	{
		NSMutableArray *oldestSearchKeys;
		NSMutableArray *oldestCollectionKeys;
		
		for (NSString *key in cachedIconImages)
		{
			CachedImage *cachedImage = [cachedIconImages valueForKey:key];
			
			NSMutableArray *oldestKeys;
			
			if (cachedImage.weight == ImageCacheWeight_Search)
				oldestKeys = oldestSearchKeys;
			else
				oldestKeys = oldestCollectionKeys;
				
			bool inserted = false;
			for (int i = 0; i < [oldestKeys count]; ++i)
			{
				if (cachedImage.order < ((CachedImage *)oldestKeys[i]).order)
				{
					[oldestKeys insertObject:key atIndex:i];
					
					inserted = true;
					break;
				}
			}
			
			if (!inserted)
				[oldestKeys addObject:key];
		}
		
		int numSearchKeys = (int)[oldestSearchKeys count];
		
		int numRemoved = 0;
		if (numSearchKeys > ICON_IMAGES_MIN_NUM_CACHED_SEARCH)
		{
			numRemoved = numSearchKeys - ICON_IMAGES_MIN_NUM_CACHED_SEARCH;
			
			if (numRemoved > ICON_IMAGES_REMOVAL_SIZE)
				numRemoved = ICON_IMAGES_REMOVAL_SIZE;
			
			for (int i = 0; i < numRemoved; ++i)
				[cachedIconImages removeObjectForKey:oldestSearchKeys[i]];
		}
		
		if (numRemoved < ICON_IMAGES_REMOVAL_SIZE)
		{
			
		}
	}
}

+ (void)cacheDetailsImage:(NSString *) key image:(UIImage *) image
{
	[cachedDetailsImages setValue:[[CachedImage alloc] init:image
													 weight:ImageCacheWeight_Search
													  order:++cachedDetailsImageOrder]
						   forKey:key];
	
	[self checkOverflow:cachedDetailsImages weight:ImageCacheWeight_Search order:cachedDetailsImageOrder];
}


+ (void)checkOverflow:(NSMutableDictionary *) cachedImages
				order:(long) order
		 maxNumCached:(int)  maxNumCached
numToRemoveOnOverflow:(int)  numToRemoveOnOverflow
{
	if ([cachedImages count] > maxNumCached)
	{
		if ([cachedIconImagesSearch count] >
		NSMutableArray higestOrderKeys = [NSMutableArray array];
		for (int i = maxNumCached; )
		
		long minOrder = (order - maxNumCached) + numToRemoveOnOverflow;
		
		NSMutableArray *foundKeys = [NSMutableArray array];
		for (NSString *key in cachedDetailsImages)
		{
			if (((CachedImage *)[cachedDetailsImages valueForKey:key]).order < minOrder)
				[foundKeys addObject:key];
		}
		
		[cachedDetailsImages removeObjectsForKeys:foundKeys];
	}
}

@end*/
