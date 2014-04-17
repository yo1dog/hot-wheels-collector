//
//  HotWheels2APIErrors.h
//  HotWheels 2.0
//
//  Created by Mike on 4/13/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

// Base
// abstract
@interface HotWheels2APIError : NSObject
- (NSString *)getMessage;
- (NSURLRequest *)getRequest;

- (UIAlertView *)createAlert:(NSString *)title;
- (UIAlertView *)createAlert:(NSString *)title withMessagePrefix:(NSString *)messagePrefix;
@end




// Request Error
@interface HotWheels2APIRequestError : HotWheels2APIError
- (id)initWithRequest:(NSURLRequest *)request andError:(NSError *)error;
- (id)initWithRequest:(NSURLRequest *)request andError:(NSError *)error andMessge:(NSString *)message;

- (NSError *)getInternalError;
@end




// Invalid Response
// abstract
@interface HotWheels2APIInvalidResponseError : HotWheels2APIError
- (NSHTTPURLResponse *)getResponse;
@end



// Invaid Status Code
@interface HotWheels2APIInvalidHTTPStatusCodeError : HotWheels2APIInvalidResponseError
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andExpectedStatusCode:(int)statusCode;
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andExpectedStatusCode:(int)statusCode andMessage:(NSString *)message;

- (int)getExpectedStatusCode;
@end

// Invalid JSON
@interface HotWheels2APIInvalidJSONError : HotWheels2APIInvalidResponseError
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andError:(NSError *)error;
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andError:(NSError *)error andMessage:(NSString *)message;

- (NSError *)getJSONParseError;
@end

// Invalid JSON Type
@interface HotWheels2APIInvalidJSONTypeError : HotWheels2APIInvalidResponseError
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andJSONType:(NSString *)type andExpectedJSONType:(NSString *)expectedType;
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andJSONType:(NSString *)type andExpectedJSONType:(NSString *)expectedType andMessage:(NSString *)message;

- (NSString *)getJSONType;
- (NSString *)getExpectedJSONType;
@end

// Invalid Image
@interface HotWheels2APIInvalidImageError : HotWheels2APIInvalidResponseError
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response;
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andMessage:(NSString *)message;
@end