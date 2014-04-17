//
//  HotWheels2APIErrors.m
//  HotWheels 2.0
//
//  Created by Mike on 4/13/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "HotWheels2APIErrors.h"

// Base
// abstract
@interface HotWheels2APIError ()
@property(nonatomic, strong) NSURLRequest *request;
@property(nonatomic, strong) NSString     *message;
@end

@implementation HotWheels2APIError
- (id)initWithRequest:(NSURLRequest *)request andMessage:(NSString *)message;
{
	self = [super init];
	self.request = request;
	self.message = message;
	
	NSLog(@"ERROR: %@", message);
	
	// TODO: report errors
	return self;
}

- (NSString *)getMessage
{
	return self.message;
}
- (NSURLRequest *)getRequest
{
	return self.request;
}

- (UIAlertView *)createAlert:(NSString *)title
{
	return [self createAlert:title withMessagePrefix:nil];
}
- (UIAlertView *)createAlert:(NSString *)title withMessagePrefix:(NSString *)messagePrefix;
{
	NSString *message;
	
	if ([self isKindOfClass:[HotWheels2APIInvalidResponseError class]])
		message = [(HotWheels2APIInvalidResponseError *)self getMessage];
	else if ([self isKindOfClass:[HotWheels2APIRequestError class]])
		message = [@"Unable to connect to the server. Please check your internet connection.\n\n" stringByAppendingString:[(HotWheels2APIRequestError *)self getInternalError].localizedDescription];
	else
		message = @"An error has occured.";
	
	if (messagePrefix)
		message = [[messagePrefix stringByAppendingString:@"\n\n"] stringByAppendingString:message];
	
	return [[UIAlertView alloc]initWithTitle: title
									 message: message
									delegate: nil
						   cancelButtonTitle: @"OK"
						   otherButtonTitles: nil, nil];
}
@end




// Request Error
@interface HotWheels2APIRequestError ()
@property(nonatomic, strong) NSError *internalError;
@end

@implementation HotWheels2APIRequestError
- (id)initWithRequest:(NSURLRequest *)request andError:(NSError *)error
{
	self = [self initWithRequest:request andError:error andMessge:[NSString stringWithFormat:@"An error ocurred while making a request to the server: %@", error]];
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request andError:(NSError *)error andMessge:(NSString *)message
{
	self = [super initWithRequest:request andMessage:message];
	self.internalError = error;
	
	return self;
}

- (NSError *)getInternalError
{
	return self.internalError;
}
@end




// Response Error
// abstract
@interface HotWheels2APIInvalidResponseError ()
@property(nonatomic, strong) NSHTTPURLResponse *response;
@end

@implementation HotWheels2APIInvalidResponseError
- (id)initWithRequest:(NSURLRequest *)request andMessage:(NSString *)message
{
	[NSException raise:@"Invalid init called." format:@"Should call initWithRequest:andResponse:andMessage: instead."];
	return nil;
}

- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andMessage:(NSString *)message;
{
	self = [super initWithRequest:request andMessage:message];
	self.response = response;
	
	return self;
}

- (NSHTTPURLResponse *)getResponse
{
	return self.response;
}
@end




// Invalid Status Code
@interface HotWheels2APIInvalidHTTPStatusCodeError ()
@property int expectedStatusCode;
@end

@implementation HotWheels2APIInvalidHTTPStatusCodeError
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andExpectedStatusCode:(int)statusCode
{
	self = [self initWithRequest:request andResponse:response andMessage:[NSString stringWithFormat:@"Server returned an invalid status code: %i", (int)response.statusCode]];
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andExpectedStatusCode:(int)statusCode andMessage:(NSString *)message
{
	self = [super initWithRequest:request andResponse:response andMessage:message];
	self.expectedStatusCode = response.statusCode;
	
	return self;
}

- (int)getExpectedStatusCode
{
	return self.expectedStatusCode;
}
@end


// Invalid JSON
@interface HotWheels2APIInvalidJSONError ()
@property(nonatomic, strong) NSError *jsonParseError;
@end

@implementation HotWheels2APIInvalidJSONError
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andError:(NSError *)error
{
	self = [self initWithRequest:request andResponse:response andError:error andMessage:[NSString stringWithFormat:@"An error occured while parsing a response body as JSON: %@", error]];
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andError:(NSError *)error andMessage:(NSString *)message
{
	self = [super initWithRequest:request andResponse:response andMessage:message];
	self.jsonParseError = error;
	
	return self;
}

- (NSError *)getJSONParseError
{
	return self.jsonParseError;
}
@end


// Invalid JSON Type
@interface HotWheels2APIInvalidJSONTypeError ()
@property(nonatomic, strong) NSString *jsonType;
@property(nonatomic, strong) NSString *expectedJSONType;
@end

@implementation HotWheels2APIInvalidJSONTypeError
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andJSONType:(NSString *)type andExpectedJSONType:(NSString *)expectedType
{
	self = [self initWithRequest:request andResponse:response andJSONType:type andExpectedJSONType:expectedType andMessage:[NSString stringWithFormat:@"Server returned a JSON %@ when it expect a JSON %@.", type, expectedType]];
	return self;
}
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andJSONType:(NSString *)type andExpectedJSONType:(NSString *)expectedType andMessage:(NSString *)message
{
	self = [super initWithRequest:request andResponse:response andMessage:message];
	self.jsonType = type;
	self.expectedJSONType = expectedType;
	
	return self;
}

- (NSString *)getJSONType
{
	return self.jsonType;
}

- (NSString *)getExpectedJSONType
{
	return self.expectedJSONType;
}
@end


// Invalid Image
@implementation HotWheels2APIInvalidImageError
- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response
{
	self = [self initWithRequest:request andResponse:response andMessage:@"An error occured while creating an image out of a response body."];
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request andResponse:(NSHTTPURLResponse *)response andMessage:(NSString *)message
{
	self = [super initWithRequest:request andResponse:response andMessage:message];
	return self;
}
@end