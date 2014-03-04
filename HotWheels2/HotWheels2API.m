//
//  HotWheels2API.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "HotWheels2API.h"
#import "Car.h"

@implementation HotWheels2API
static NSString *BASE_URL = @"http://hotwheels2.awesomebox.net/api/";



//static NSMutableDictionary *searchCahce = NULL;

+ (void)   search:(NSString *)                                     query
		   userID:(NSString *)                                     userID
completionHandler:(void (^)(NSError *error, NSMutableArray *cars)) handler
{
	/*NSString *searchCacheKey = [query stringByAppendingString:(userID? : @"NULL")];
	
	if (searchCahce == NULL)
		searchCahce = [[NSMutableDictionary alloc] init];
	
	NSMutableArray *cachedSearch = [searchCahce valueForKey:searchCacheKey];
	if (cachedSearch)
		return handler(NULL, cachedSearch);*/
	
	
	NSString *urlStr = [NSString stringWithFormat:@"%@search.php?query=%@", BASE_URL, [HotWheels2API encodeURIComponent:query]];
	
	if (userID)
		urlStr = [urlStr stringByAppendingFormat:@"&userID=%@", [HotWheels2API encodeURIComponent:userID]];
	
	[HotWheels2API getCarsList:urlStr completionHandler:handler];
	
	
	/*[HotWheels2API getCarsList:urlStr completionHandler:^(NSError *error, NSMutableArray *cars)
	{
		if (!error)
			[searchCahce setValue:cars forKey:[searchCacheKey]
		
		handler(error, cars);
	}];*/
}


+ (void)getCollection:(NSString *) userID
			  handler:(void (^)(NSError *error, NSMutableArray *cars)) handler
{
	NSString *urlStr = [NSString stringWithFormat:@"%@getCollection.php?userID=%@", BASE_URL, [HotWheels2API encodeURIComponent:userID]];
	[HotWheels2API getCarsList:urlStr completionHandler:handler];
}

+ (void)getCollectionRemovals:(NSString *) userID
			  handler:(void (^)(NSError *error, NSMutableArray *cars)) handler
{
	NSString *urlStr = [NSString stringWithFormat:@"%@getCollectionRemovals.php?userID=%@", BASE_URL, [HotWheels2API encodeURIComponent:userID]];
	[HotWheels2API getCarsList:urlStr completionHandler:handler];
}

+ (void)getCarFromQRCode:(NSString *) qrCodeData
				  userID:(NSString *) userID
			  handler:(void (^)(NSError *error, Car *car)) handler
{
	NSString *urlStr = [NSString stringWithFormat:@"%@getCarFromQRCode.php?qrCodeData=%@", BASE_URL, [HotWheels2API encodeURIComponent:qrCodeData]];
	
	if (userID)
		urlStr = [urlStr stringByAppendingFormat:@"&userID=%@", [HotWheels2API encodeURIComponent:userID]];
	
	[HotWheels2API makeRequest:urlStr httpMethod:@"GET" httpBody:NULL completionHandler:^(NSData *data, NSError *error)
	{
		if (error)
			return handler(error, NULL);
		
		NSObject *jsonObject = [HotWheels2API parseJSON:data];
		
		if ([jsonObject isKindOfClass:[NSError class]])
			return handler((NSError *)jsonObject, NULL);
		
		if (![jsonObject isKindOfClass:[NSDictionary class]])
		{
			NSLog(@"JSON is not a single object.");
			
			return handler([NSError errorWithDomain:@"hotWheels2" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid HTTP response.", nil)}], NULL);
		}
		
		Car *car = [[Car alloc] init:(NSDictionary *)jsonObject];
		
		handler(NULL, car);
	}];
}


+ (void)setCarOwned:(NSString *)               userID
			  carID:(NSString *)               carID
			  owned:(bool)                     owned
  completionHandler:(void (^)(NSError *error)) handler
{
	NSString *urlStr = [NSString stringWithFormat:@"%@setCarOwned.php", BASE_URL];
	const char *httpBodyStr = [[NSString stringWithFormat:@"userID=%@&carID=%@&owned=%@", [HotWheels2API encodeURIComponent:userID], [HotWheels2API encodeURIComponent:carID], owned? @"1" : @"0"] UTF8String];
	
	NSData *httpBody = [NSData dataWithBytes:httpBodyStr length:strlen(httpBodyStr)];
	
	[HotWheels2API makeRequest:urlStr httpMethod:@"POST" httpBody:httpBody completionHandler:^(NSData *data, NSError *error)
	{
		if (error)
			return handler(error);
		
		handler(NULL);
	}];
}



+ (void)getCarsList:(NSString *)                                     urlStr
  completionHandler:(void (^)(NSError* error, NSMutableArray *cars)) handler
{
	[HotWheels2API makeRequest:urlStr httpMethod:@"GET" httpBody:NULL completionHandler:^(NSData *data, NSError *error)
	{
		if (error)
			return handler(error, NULL);
		
		NSObject *jsonObject = [HotWheels2API parseJSON:data];
		
		if ([jsonObject isKindOfClass:[NSError class]])
			 return handler((NSError *)jsonObject, NULL);
		
		if (![jsonObject isKindOfClass:[NSArray class]])
		{
			NSLog(@"JSON is not array.");
			
			return handler([NSError errorWithDomain:@"hotWheels2" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid HTTP response.", nil)}], NULL);
		}
		
		NSArray *carsJSON = (NSArray *)jsonObject;
		NSMutableArray *cars = [NSMutableArray array];
		
		for (NSDictionary *carJSON in carsJSON)
			[cars addObject:[[Car alloc] init:carJSON]];
		
		handler(NULL, cars);
	}];
}





// TODO: add wieghts and times to chached images so we don't run out of memory
static NSMutableDictionary *imageCache = NULL;
static NSMutableArray *detailsImageCache = NULL;
+ (void) initialize
{
	[super initialize];
	imageCache        = [[NSMutableDictionary alloc] init];
	detailsImageCache = [NSMutableArray array];
}

+ (void) getImage:(NSString *) urlStr
	imageCacheKey:(NSString *) imageCacheKey
   imageIsDetails:(bool)       imageIsDetails
completionHandler:(void (^)(NSError* error, UIImage *image)) handler
{
	UIImage *cachedImage = NULL;
	
	if (imageIsDetails)
	{
		for (NSArray *cache in detailsImageCache)
		{
			if ([imageCacheKey isEqualToString:cache[0]])
			{
				cachedImage = cache[1];
				break;
			}
		}
	}
	else
		cachedImage = [imageCache valueForKey:imageCacheKey];
	
	if (cachedImage)
		return handler(NULL, cachedImage);
	
	[HotWheels2API makeRequest:urlStr httpMethod:@"GET" httpBody:NULL completionHandler:^(NSData *data, NSError *error)
	{
		if (error)
			return handler(error, NULL);
		
		UIImage *image = [UIImage imageWithData:data];
		
		if (!image)
		{
			NSLog(@"HTTP image request (%@) error: invalid image", urlStr);
			
			return handler([NSError errorWithDomain:@"hotWheels2" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid HTTP response.", nil)}], NULL);
		}
		
		if (imageIsDetails)
		{
			bool cacheFound = false;
			for (int i = 0; i < [detailsImageCache count]; ++i)
			{
				if ([imageCacheKey isEqualToString:detailsImageCache[i][0]])
				{
					detailsImageCache[i][1] = image;
					
					cacheFound = true;
					break;
				}
			}
			
			if (!cacheFound)
			{
				[detailsImageCache insertObject:[NSArray arrayWithObjects:imageCacheKey, image, nil] atIndex:0];
				
				if ([detailsImageCache count] > 20)
					[detailsImageCache removeObjectAtIndex:20];
			}
		}
		else
			[imageCache setValue:image forKey:imageCacheKey];
		
		handler(NULL, image);
	}];
}



+ (void)makeRequest:(NSString *) urlStr
		 httpMethod:(NSString *) httpMethod
		   httpBody:(NSData *)   httpBody
  completionHandler:(void (^)(NSData* data, NSError* error)) handler
{
	NSURL *url = [[NSURL alloc] initWithString:urlStr];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod: httpMethod];
	[request setHTTPBody: httpBody];
	
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
	{
		if (error)
		{
			NSLog(@"HTTP request (%@) error: %@", urlStr, error);
			
			return handler(NULL, error);
		}
		
		int statusCode = (int)((NSHTTPURLResponse *)response).statusCode;
		if (statusCode != 200)
		{
			NSLog(@"HTTP request (%@) status code: %i", urlStr, statusCode);
			
			return handler(NULL, [NSError errorWithDomain:@"hotWheels2" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid HTTP response.", nil), @"statusCode": @(statusCode)}]);
		}
		
		handler(data, NULL);
	}];
}

	 
+ (NSObject *)parseJSON:(NSData *) data
{
	NSError *jsonParsingError = NULL;
	NSObject *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
	
	if (jsonParsingError)
	{
		NSLog(@"JSON parse error: %@", jsonParsingError);
		
		return jsonParsingError;
	}
	
	return jsonObject;
}


+ (NSString *)encodeURIComponent:(NSString *) uriComponenet
{
	return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																	 CFBridgingRetain(uriComponenet),
																	 NULL,
																	 CFSTR(":/?#[]@!$&'()*+,;="),
																	 kCFStringEncodingUTF8));
}
@end
