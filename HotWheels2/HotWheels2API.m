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



//static NSMutableDictionary *searchCahce;

+ (void)   search:(NSString *)                                     query
		   userID:(NSString *)                                     userID
completionHandler:(void (^)(NSError *error, NSMutableArray *cars)) handler
{
	/*NSString *searchCacheKey = [query stringByAppendingString:(userID? : @"NULL")];
	
	if (!searchCahce)
		searchCahce = [[NSMutableDictionary alloc] init];
	
	NSMutableArray *cachedSearch = [searchCahce valueForKey:searchCacheKey];
	if (cachedSearch)
		return handler(nill, cachedSearch);*/
	
	
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
	
	[HotWheels2API makeRequest:urlStr httpMethod:@"GET" httpBody:nil completionHandler:^(NSData *data, NSError *error)
	{
		if (error)
			return handler(error, nil);
		
		NSObject *jsonObject = [HotWheels2API parseJSON:data];
		
		if ([jsonObject isKindOfClass:[NSError class]])
			return handler((NSError *)jsonObject, nil);
		
		if (![jsonObject isKindOfClass:[NSDictionary class]])
		{
			NSLog(@"JSON is not a single object.");
			
			return handler([NSError errorWithDomain:@"hotWheels2" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid HTTP response.", nil)}], nil);
		}
		
		Car *car = [[Car alloc] init:(NSDictionary *)jsonObject];
		
		handler(nil, car);
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
		
		handler(nil);
	}];
}



+ (void)getCarsList:(NSString *)                                     urlStr
  completionHandler:(void (^)(NSError* error, NSMutableArray *cars)) handler
{
	[HotWheels2API makeRequest:urlStr httpMethod:@"GET" httpBody:nil completionHandler:^(NSData *data, NSError *error)
	{
		if (error)
			return handler(error, nil);
		
		NSObject *jsonObject = [HotWheels2API parseJSON:data];
		
		if ([jsonObject isKindOfClass:[NSError class]])
			 return handler((NSError *)jsonObject, nil);
		
		if (![jsonObject isKindOfClass:[NSArray class]])
		{
			NSLog(@"JSON is not array.");
			
			return handler([NSError errorWithDomain:@"hotWheels2" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid HTTP response.", nil)}], nil);
		}
		
		NSArray *carsJSON = (NSArray *)jsonObject;
		NSMutableArray *cars = [NSMutableArray array];
		
		for (NSDictionary *carJSON in carsJSON)
			[cars addObject:[[Car alloc] init:carJSON]];
		
		handler(nil, cars);
	}];
}



+ (void)addCustomCar:(Car *)               car
   completionHandler:(void (^)(NSError *)) handler
{
	NSString *boundary = @"gc0p4Jq0M2Yt08jU534c0p";
	NSDictionary *headers = @{
		@"Content-Type": [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
	};
	
	// build body
	NSMutableData *body = [NSMutableData data];
	[HotWheels2API addMultipartParam:@"name"                paramValueString:car.name                boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"segment"             paramValueString:car.segment             boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"series"              paramValueString:car.series              boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"make"                paramValueString:car.make                boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"color"               paramValueString:car.color               boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"style"               paramValueString:car.style               boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"customToyNumber"     paramValueString:car.customToyNumber     boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"distinguishingNotes" paramValueString:car.distinguishingNotes boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"barcodeData"         paramValueString:car.barcodeData         boundary:boundary body:body];
	
	if (!car.detailImage)
	{
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", @"carPicture", @"filename.jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];

		[body appendData: UIImageJPEGRepresentation(car.detailImage, 0.7f)];
	}
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
	// make request
	NSString *urlStr = [NSString stringWithFormat:@"%@addCustomCar.phpASDF", BASE_URL];
	[HotWheels2API makeRequest:urlStr httpMethod:@"POST" httpBody:body headers:headers completionHandler:^(NSData *data, NSError *error)
	{
		sleep(3);
		return handler(error);
	}];
}





// TODO: add wieghts and times to chached images so we don't run out of memory
static NSMutableDictionary *iconImageCache;
static NSMutableDictionary *detailsImageCache;
+ (void) initialize
{
	[super initialize];
	iconImageCache    = [[NSMutableDictionary alloc] init];
	detailsImageCache = [[NSMutableDictionary alloc] init];
}

+ (UIImage *) getImageFromCache:(NSString *) imageCacheKey
				 imageIsDetails:(bool)       imageIsDetails
{
	return (UIImage *)[(imageIsDetails? detailsImageCache : iconImageCache) valueForKey:imageCacheKey];
}

+ (void) getImage:(NSString *) urlStr
	imageCacheKey:(NSString *) imageCacheKey
   imageIsDetails:(bool)       imageIsDetails
completionHandler:(void (^)(NSError* error, UIImage *image, bool wasCached)) handler
{
	UIImage *cachedImage = [HotWheels2API getImageFromCache:imageCacheKey imageIsDetails:imageIsDetails];
	
	if (cachedImage)
		return handler(nil, cachedImage, true);
	
	[HotWheels2API makeRequest:urlStr httpMethod:@"GET" httpBody:nil completionHandler:^(NSData *data, NSError *error)
	{
		//[NSThread sleepForTimeInterval:(500 + (rand() % 500)) * 0.001f];
		
		if (error)
			return handler(error, nil, false);
		
		UIImage *image = [UIImage imageWithData:data];
		
		if (!image)
		{
			NSLog(@"HTTP image request (%@) error: invalid image", urlStr);
			
			return handler([NSError errorWithDomain:@"hotWheels2" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid HTTP response.", nil)}], nil, false);
		}
		
		
		[(imageIsDetails? detailsImageCache : iconImageCache) setValue:image forKey:imageCacheKey];
		
		handler(nil, image, false);
	}];
}


+ (void)makeRequest:(NSString *) urlStr
		 httpMethod:(NSString *) httpMethod
		   httpBody:(NSData *)   httpBody
  completionHandler:(void (^)(NSData* data, NSError* error)) handler
{
	[HotWheels2API makeRequest:urlStr httpMethod:httpMethod httpBody:httpBody headers:nil completionHandler:handler];
}

+ (void)makeRequest:(NSString *)     urlStr
		 httpMethod:(NSString *)     httpMethod
		   httpBody:(NSData *)       httpBody
			headers:(NSDictionary *) headers
  completionHandler:(void (^)(NSData* data, NSError* error)) handler
{
	NSURL *url = [[NSURL alloc] initWithString:urlStr];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod: httpMethod];
	[request setHTTPBody: httpBody];
	
	if (!headers)
	{
		for (NSString* headerName in headers)
			[request addValue:headers[headerName] forHTTPHeaderField: headerName];
	}
	
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error)
			{
				NSLog(@"HTTP request (%@) error: %@", urlStr, error);
				
				return handler(data, error);
			}
			
			int statusCode = (int)((NSHTTPURLResponse *)response).statusCode;
			if (statusCode != 200 && statusCode != 201)
			{
				NSLog(@"HTTP request (%@) status code: %i", urlStr, statusCode);
				
				return handler(data, [NSError errorWithDomain:@"hotWheels2" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid HTTP response.", nil), @"statusCode": @(statusCode)}]);
			}
			
			handler(data, nil);
		});
	}];
}

	 
+ (NSObject *)parseJSON:(NSData *) data
{
	NSError *jsonParsingError;
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
	return [uriComponenet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (void)addMultipartParam:(NSString *)      paramName
		 paramValueString:(NSString *)      paramValueString
				 boundary:(NSString *)      boundary
					 body:(NSMutableData *) body
{
	[HotWheels2API addMultipartParam:paramName paramValueData:[paramValueString dataUsingEncoding:NSUTF8StringEncoding] boundary:boundary body:body];
}
+ (void)addMultipartParam:(NSString *)      paramName
		   paramValueBool:(bool)            paramValueBool
				 boundary:(NSString *)      boundary
					 body:(NSMutableData *) body
{
	[HotWheels2API addMultipartParam:paramName paramValueData:[(paramValueBool? @"1" : @"0") dataUsingEncoding:NSUTF8StringEncoding] boundary:boundary body:body];
}
+ (void)addMultipartParam:(NSString *)      paramName
			paramValueInt:(int)             paramValueInt
				 boundary:(NSString *)      boundary
					 body:(NSMutableData *) body
{
	[HotWheels2API addMultipartParam:paramName paramValueData:[[NSString stringWithFormat:@"%i", paramValueInt] dataUsingEncoding:NSUTF8StringEncoding] boundary:boundary body:body];
}
+ (void)addMultipartParam:(NSString *)      paramName
		   paramValueData:(NSData *)        paramValueData
				 boundary:(NSString *)      boundary
					 body:(NSMutableData *) body
{
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", paramName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:paramValueData];
}
@end
