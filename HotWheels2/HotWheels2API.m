//
//  HotWheels2API.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "HotWheels2API.h"
#import "ImageCache.h"
#import "Car.h"

NSString *HW2_API_BASE_URL = @"http://hotwheels2.awesomebox.net/api/";


@implementation HotWheels2API

///////////////////////////
// Search
//
// Uses the Hot Wheels 2 API search endpoint to find cars.
// Handler will be called with an error or a list of cars, but never both.

+ (void)   search:(NSString *) query
		   userID:(NSString *) userID
			 page:(int)        page
completionHandler:(void (^)(HotWheels2APIError *error, NSMutableArray *cars, int numPages)) handler
{
	NSString *url = [NSString stringWithFormat:@"%@search.php?query=%@&page=%i", HW2_API_BASE_URL, [HotWheels2API encodeURIComponent:query], page];
	
	if (userID)
		url = [url stringByAppendingFormat:@"&userID=%@", [HotWheels2API encodeURIComponent:userID]];
	
	[HotWheels2API getCarListFromURL:url page:page completionHandler:handler];
}


///////////////////////////
// Get Colection
//
// Uses the Hot Wheels 2 API collection endpoint to get a user's collection.
// Handler will be called with an error or a list of cars, but never both.

+ (void)getCollection:(NSString *) userID
	completionHandler:(void (^)(HotWheels2APIError *error, NSMutableArray *cars)) handler
{
	NSString *url = [NSString stringWithFormat:@"%@getCollection.php?userID=%@", HW2_API_BASE_URL, [HotWheels2API encodeURIComponent:userID]];
	[HotWheels2API getCarListFromURL:url completionHandler:handler];
}


///////////////////////////
// Get Colection Removals
//
// Uses the Hot Wheels 2 API collection removals endpoint to get the cars a user has removed from their collection.
// Handler will be called with an error or a list of cars, but never both.

+ (void)getCollectionRemovals:(NSString *) userID
			completionHandler:(void (^)(HotWheels2APIError *error, NSMutableArray *cars)) handler
{
	NSString *url = [NSString stringWithFormat:@"%@getCollectionRemovals.php?userID=%@", HW2_API_BASE_URL, [HotWheels2API encodeURIComponent:userID]];
	[HotWheels2API getCarListFromURL:url completionHandler:handler];
}


///////////////////////////
// Get Car From QR Code
//
// Uses the Hot Wheels 2 API QR code endpoint to get a car based on a qr Code.
// Handler will be called with an error or a cars, but never both.

+ (void)getCarFromQRCode:(NSString *) qrCodeData
				  userID:(NSString *) userID
	   completionHandler:(void (^)(HotWheels2APIError *error, Car *car)) handler
{
	NSString *url = [NSString stringWithFormat:@"%@getCarFromQRCode.php?qrCodeData=%@", HW2_API_BASE_URL, [HotWheels2API encodeURIComponent:qrCodeData]];
	
	if (userID)
		url = [url stringByAppendingFormat:@"&userID=%@", [HotWheels2API encodeURIComponent:userID]];
	
	[HotWheels2API getCarFromURL:url completionHandler:handler];
}


///////////////////////////
// Set Car Owned
//
// Uses the Hot Wheels 2 API set owned endpoint to add a car to the user's collection.
// Handler will be called with an error or a timestamp, but never both.
+ (void)setCarOwned:(NSString *) userID
			  carID:(NSString *) carID
  completionHandler:(void (^)(HotWheels2APIError *error, int ownedTimestamp, bool alreadyOwned)) handler
{
	NSString *url = [NSString stringWithFormat:@"%@setCarOwned.php", HW2_API_BASE_URL];
	
	// construct the body
	const char *httpBodyString = [[NSString stringWithFormat:@"userID=%@&carID=%@", [HotWheels2API encodeURIComponent:userID], [HotWheels2API encodeURIComponent:carID]] UTF8String];
	NSData *httpBody = [NSData dataWithBytes:httpBodyString length:strlen(httpBodyString)];
	
	// make request
	[HotWheels2API getJSONFromURL:url httpMethod:@"POST" httpBody:httpBody completionHandler:^(HotWheels2APIError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSObject *jsonObject)
	{
		if (error)
			return handler(error, -1, false);
		
		// make sure we got a 200 back
		if (response.statusCode != 200)
			return handler([[HotWheels2APIInvalidHTTPStatusCodeError alloc] initWithRequest:request andResponse:response andExpectedStatusCode:200], -1, false);
		
		// make sure we got a single object back
		if (![jsonObject isKindOfClass:[NSDictionary class]])
			return handler([[HotWheels2APIInvalidJSONTypeError alloc] initWithRequest:request andResponse:response andJSONType:@"Array" andExpectedJSONType:@"Object"], -1, false);
		
		// get the ownedTimestamp and alreadyOwned values
		NSDictionary *json = (NSDictionary *)jsonObject;
		int ownedTimestamp = [(NSNumber *)[json objectForKey:@"ownedTimestamp"] intValue];
		bool alreadyOwned  = [(NSNumber *)[json objectForKey:@"alreadyOwned"] isEqualToNumber:[NSNumber numberWithInt:1]];
		
		handler(nil, ownedTimestamp, alreadyOwned);
	}];
}

///////////////////////////
// Set Car Unowned
//
// Uses the Hot Wheels 2 API set owned endpoint to remove a car from a user's collection.
+ (void)setCarUnowned:(NSString *) userID
				carID:(NSString *) carID
	completionHandler:(void (^)(HotWheels2APIError *error)) handler
{
	NSString *url = [NSString stringWithFormat:@"%@setCarUnowned.php", HW2_API_BASE_URL];
	
	// construct the body
	const char *httpBodyString = [[NSString stringWithFormat:@"userID=%@&carID=%@", [HotWheels2API encodeURIComponent:userID], [HotWheels2API encodeURIComponent:carID]] UTF8String];
	NSData *httpBody = [NSData dataWithBytes:httpBodyString length:strlen(httpBodyString)];
	
	// make request
	[HotWheels2API makeRequest:url httpMethod:@"POST" httpBody:httpBody completionHandler:^(HotWheels2APIRequestError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSData *responseBody)
	 {
		 if (error)
			 return handler(error);
		 
		 // make sure we got a 204 back
		 if (response.statusCode != 204)
			 return handler([[HotWheels2APIInvalidHTTPStatusCodeError alloc] initWithRequest:request andResponse:response andExpectedStatusCode:204]);
		 
		 handler(nil);
	 }];
}



///////////////////////////
// Add Custom Car
//
// Uses the Hot Wheels 2 API to add a custom car endpoint to create a new custom car.

// TODO: add addToCollection option
+ (void)addCustomCar:(Car *)      car
			  userID:(NSString *) userID
	 addToCollection:(bool)       addToCollection
   completionHandler:(void (^)(HotWheels2APIError *)) handler
{
	NSString *url = [NSString stringWithFormat:@"%@addCustomCar.php?userID=%@&addToCollection=%i", HW2_API_BASE_URL, [HotWheels2API encodeURIComponent:userID], addToCollection];
	
	NSString *boundary = @"gc0p4Jq0M2Yt08jU534c0p";
	NSDictionary *headers = @{
		@"Content-Type": [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
	};
	
	// build body
	NSMutableData *body = [NSMutableData data];
	//[HotWheels2API addMultipartParam:@"createdByUser"       paramValueString:userID                  boundary:boundary body:body];
	//[HotWheels2API addMultipartParam:@"addToCollection"     paramValueBool:  addToCollection         boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"name"                paramValueString:car.name                boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"segment"             paramValueString:car.segment             boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"series"              paramValueString:car.series              boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"make"                paramValueString:car.make                boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"color"               paramValueString:car.color               boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"style"               paramValueString:car.style               boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"customToyNumber"     paramValueString:car.customToyNumber     boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"distinguishingNotes" paramValueString:car.distinguishingNotes boundary:boundary body:body];
	[HotWheels2API addMultipartParam:@"barcodeData"         paramValueString:car.barcodeData         boundary:boundary body:body];
	
	if (car.detailImage)
	{
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", @"carPicture", @"filename.jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];

		[body appendData: UIImageJPEGRepresentation(car.detailImage, 0.7f)];
	}
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// make request
	[HotWheels2API makeRequest:url httpMethod:@"POST" httpBody:body headers:headers completionHandler:^(HotWheels2APIRequestError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSData *responseBody)
	{
		if (error)
			return handler(error);
		
		// make sure we got a 201 back
		if (response.statusCode != 201)
			return handler([[HotWheels2APIInvalidHTTPStatusCodeError alloc] initWithRequest:request andResponse:response andExpectedStatusCode:201]);
		
		handler(nil);
	}];
}




///////////////////////////
// Get Image
//
// Checks the image cache first then gets an image at the given URL.
// Handler will be called with an error or an image, but never both.

+ (void) getImage:(NSString *) url
	imageCacheKey:(NSString *) imageCacheKey
   imageIsDetails:(bool)       imageIsDetails
completionHandler:(void (^)(HotWheels2APIError* error, UIImage *image, bool wasCached)) handler
{
	// check the cache first
	UIImage *cachedImage = [ImageCache getImage:imageCacheKey imageIsDetails:imageIsDetails];
	
	if (cachedImage)
		return handler(nil, cachedImage, true);
	
	// make request
	[HotWheels2API makeRequest:url httpMethod:@"GET" httpBody:nil completionHandler:^(HotWheels2APIRequestError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSData *responseBody)
	{
		if (error)
			return handler(error, nil, false);
		
		// make sure we got a 200 back
		if (response.statusCode != 200)
			return handler([[HotWheels2APIInvalidHTTPStatusCodeError alloc] initWithRequest:request andResponse:response andExpectedStatusCode:200], nil, false);
		
		// create an image from the response body
		UIImage *image = [UIImage imageWithData:responseBody];
		
		if (!image)
			return handler([[HotWheels2APIInvalidImageError alloc] initWithRequest:request andResponse:response], nil, false);
		
		// cache image
		[ImageCache cacheImage:image withKey:imageCacheKey imageIsDetails:imageIsDetails];
		
		handler(nil, image, false);
	}];
}







///////////////////////////
// Get JSON from URL
//
// Makes an HTTP GET request to the given URL and tries to parse the response body as JSON.
// Handler will be called with an error or a JSON object, but never both. The JSON object should be an NSDictionary or an NSArray.

+ (void)getJSONFromURL:(NSString *) url
     completionHandler:(void (^)(HotWheels2APIError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSObject *jsonObject)) handler
{
	[HotWheels2API getJSONFromURL:url httpMethod:@"GET" httpBody:nil completionHandler:handler];
}
+ (void)getJSONFromURL:(NSString *) url
			httpMethod:(NSString *) httpMethod
			  httpBody:(NSData *)   httpBody
     completionHandler:(void (^)(HotWheels2APIError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSObject *jsonObject)) handler
{
	[HotWheels2API makeRequest:url httpMethod:httpMethod httpBody:httpBody completionHandler:^(HotWheels2APIRequestError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSData *responseBody)
	{
		if (error)
			return handler(error, request, response, nil);
		
		// make sure we got a 200 back
		if (response.statusCode != 200)
			return handler([[HotWheels2APIInvalidHTTPStatusCodeError alloc] initWithRequest:request andResponse:response andExpectedStatusCode:200], request, response, nil);
		
		// parse the response as JSON
		NSError *jsonParsingError;
		NSObject *jsonObject = [NSJSONSerialization JSONObjectWithData:responseBody options:0 error:&jsonParsingError];
		
		if (jsonParsingError)
			return handler([[HotWheels2APIInvalidJSONError alloc] initWithRequest:request andResponse:response andError:jsonParsingError], request, response, nil);
		
		return handler(nil, request, response, jsonObject);
	}];
}


///////////////////////////
// Get Car List From URL
//
// Makes an HTTP GET request to the given URL and tries to parse the response body as JSON represintation of an array of cars.
// Handler will be called with an error or a list of cars, but never both.

+ (void)getCarListFromURL:(NSString *) url

		completionHandler:(void (^)(HotWheels2APIError *error, NSMutableArray *cars)) handler
{
	[HotWheels2API getJSONFromURL:url completionHandler:^(HotWheels2APIError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSObject *jsonObject)
	{
		if (error)
			return handler(error, nil);
		 
		// make sure we got an array back
		if (![jsonObject isKindOfClass:[NSArray class]])
			return handler([[HotWheels2APIInvalidJSONTypeError alloc] initWithRequest:request andResponse:response andJSONType:@"Object" andExpectedJSONType:@"Array"], nil);
		
		// convert the JSON into a list of cars
		NSArray *jsonObjects = (NSArray *)jsonObject;
		NSMutableArray *cars = [NSMutableArray array];
		
		for (NSDictionary *jsonObject in jsonObjects)
			[cars addObject:[[Car alloc] init:jsonObject]];
		
		handler(nil, cars);
	}];
}


///////////////////////////
// Get Paginated Car List From URL
//
// Makes an HTTP GET request to the given URL and tries to parse the response body as JSON represintation of a paginated list of cars.
// Handler will be called with an error or a list of cars, but never both.

+ (void)getCarListFromURL:(NSString *) url
					 page:(int)        page
		completionHandler:(void (^)(HotWheels2APIError *error, NSMutableArray *cars, int numPages)) handler
{
	[HotWheels2API getJSONFromURL:url completionHandler:^(HotWheels2APIError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSObject *jsonObject)
	{
		if (error)
			return handler(error, nil, 0);
	 
		// make sure we got an array back
		if (![jsonObject isKindOfClass:[NSDictionary class]])
			return handler([[HotWheels2APIInvalidJSONTypeError alloc] initWithRequest:request andResponse:response andJSONType:@"Array" andExpectedJSONType:@"Object"], nil, 0);
		
		// convert the JSON into a list of cars
		NSDictionary *jsonResponse = (NSDictionary *)jsonObject;
		
		// get number of pages
		int numPages;
		NSObject *numPagesObject = [jsonResponse objectForKey:@"numPages"];
		
		if (numPagesObject == (id)[NSNull null])
			numPages = 1;
		else
			numPages = [(NSNumber *)numPagesObject intValue];
		
		// get list of cars
		NSMutableArray *cars = [NSMutableArray array];
		NSArray *carObjects = [jsonResponse objectForKey:@"cars"];
		
		if (carObjects != (id)[NSNull null])
		{
			for (NSDictionary *carObject in carObjects)
				[cars addObject:[[Car alloc] init:carObject]];
		}
		
		handler(nil, cars, numPages);
	}];
}


///////////////////////////
// Get Car From URL
//
// Makes an HTTP GET request to the given URL and tries to parse the response body as JSON represintation of a single car.
// Handler will be called with an error or a car, but never both.

+ (void)getCarFromURL:(NSString *) url
	completionHandler:(void (^)(HotWheels2APIError *error, Car *car)) handler
{
	[HotWheels2API getJSONFromURL:url completionHandler:^(HotWheels2APIError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSObject *jsonObject)
	{
		if (error)
			return handler(error, nil);
		
		// make sure we got a single object back
		if (![jsonObject isKindOfClass:[NSDictionary class]])
			return handler([[HotWheels2APIInvalidJSONTypeError alloc] initWithRequest:request andResponse:response andJSONType:@"Array" andExpectedJSONType:@"Object"], nil);
		
		// convert the JSON into a car
		Car *car = [[Car alloc] init:(NSDictionary *)jsonObject];
		
		handler(nil, car);
	}];
}


	 

///////////////////////////
// Make Request
//
// Creates and executes an HTTP request to the Hot Wheels 2 server.
// Handler will be called with an error or a resposne body, but never both.

+ (void)makeRequest:(NSString *) urlStr
		 httpMethod:(NSString *) httpMethod
		   httpBody:(NSData *)   httpBody
  completionHandler:(void (^)(HotWheels2APIRequestError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSData *responseBody)) handler
{
	[HotWheels2API makeRequest:urlStr httpMethod:httpMethod httpBody:httpBody headers:nil completionHandler:handler];
}

+ (void)makeRequest:(NSString *)     urlStr
		 httpMethod:(NSString *)     httpMethod
		   httpBody:(NSData *)       httpBody
			headers:(NSDictionary *) headers
  completionHandler:(void (^)(HotWheels2APIRequestError *error, NSURLRequest *request, NSHTTPURLResponse *response, NSData *data)) handler
{
	NSURL *url = [[NSURL alloc] initWithString:urlStr];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod: httpMethod];
	[request setHTTPBody: httpBody];
	
	if (headers)
	{
		for (NSString* headerName in headers)
			[request addValue:headers[headerName] forHTTPHeaderField: headerName];
	}
	
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
	{
		if ([urlStr rangeOfString:@"setCarOwned"].location != NSNotFound)
			sleep(10);
		
		dispatch_async(dispatch_get_main_queue(), ^
		{
			if (error)
				return handler([[HotWheels2APIRequestError alloc] initWithRequest:request andError:error], (NSURLRequest *)request, (NSHTTPURLResponse *)response, nil);
			
			handler(nil, (NSURLRequest *)request, (NSHTTPURLResponse *)response, data);
		});
	}];
}






///////////////////////////
// Encoding

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
