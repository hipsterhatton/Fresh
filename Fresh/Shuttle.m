//
//  Shuttle.m
//  Shuttle
//
//  Created by Stephen Hatton on 08/04/2015.
//  Copyright (c) 2015 Stephen Hatton. All rights reserved.
//

#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#import "Shuttle.h"

#define NUMBER_OF_BACK_TO_BACK_REQUESTS 3

@implementation Shuttle

#pragma mark - Public - Lifecycle

///
// Initilize library w/ default headers
//
- (id)initWithDefaults:(NSDictionary *)defaultHeaders
{
    if (self = [super init]) {
        self = [[Shuttle alloc] init];
        
        if (!_manager) {
            _manager = [AFHTTPSessionManager new];
        }
        
        for (NSString *key in defaultHeaders) {
            [[_manager requestSerializer] setValue:[defaultHeaders valueForKey:key] forHTTPHeaderField:key];
        }
        
        _HTTPResponse = [AFHTTPResponseSerializer new];
        _JSONResponse = [AFJSONResponseSerializer new];
        _IMGResponse =  [AFImageResponseSerializer new];
        
        [self monitorConnection];
    }
    return self;
}



#pragma mark - Private - Monitor Connection

////
// Monitor device connection - on change: NSLog connection
//
- (void)monitorConnection
{
    [[_manager reachabilityManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@" ---[No Internet Connection]: %s", __PRETTY_FUNCTION__);
                _connectionType = None;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@" ---[Connection via WiFi]: %s", __PRETTY_FUNCTION__);
                _connectionType = Wifi;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@" ---[Connection via WAN]: %s", __PRETTY_FUNCTION__);
                _connectionType = WAN;
                break;
                
            default:
                NSLog(@" ---[Connection - Unknown Status]: %s", __PRETTY_FUNCTION__);
                _connectionType = Unknown;
                break;
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}



#pragma mark - Public - HTTP Request

////
// Send HTTP Request
//
- (RXPromise *)launch:(ShuttleModes)mode :(ShuttleResponses)response :(NSString *)url :(NSDictionary *)params
{
    if (_connectionType == None || _connectionType == Unknown) {
        
        NSError *error = [NSError errorWithDomain:@"ShuttleError"
                                             code:-1
                                         userInfo:@{NSLocalizedFailureReasonErrorKey: @"No/Unknown Internet Connection"}];
        
        RXPromise *errorPromise = [RXPromise new];
        [self url_failure:errorPromise :error :url];
        return errorPromise;
    }
    
    return [self _launchRequestReturnPromise:mode :response :url :params]
    .then(^id(id result) {
        return result;
    }, nil)
    .then(nil, ^id(NSError *error) {
        if (_numberOfBackToBackRequests == NUMBER_OF_BACK_TO_BACK_REQUESTS) {
            NSLog(@"Networking Failed Too Many Times...");
            return error;
        } else {
            _numberOfBackToBackRequests++;
            NSLog(@"Networking Failed: %d", _numberOfBackToBackRequests);
            return [self launch:mode :response :url :params];
        }
    });
    }



#pragma mark - Private - HTTP Request Callback

////
// Send HTTP Request and fire callback method on response (success -or- failure)
//
- (RXPromise *)_launchRequestReturnPromise:(ShuttleModes)mode :(ShuttleResponses)response :(NSString *)url :(NSDictionary *)params
{
    RXPromise *promise = [RXPromise new];
    
    if (response == JSON) {
        [_manager setResponseSerializer:_JSONResponse];
    } else if (response == HTTP) {
        [_manager setResponseSerializer:_HTTPResponse];
    } else {
        [_manager setResponseSerializer:_IMGResponse];
    }
    
    if (mode == GET) {
        
        NSLog(@"...GET Request Sent...");
        
        [_manager GET:url parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [self url_success:promise :responseObject :url];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            [self url_failure:promise :error :url];
        }];
        
    } else if (mode == POST) {
        
        NSLog(@"...POST Request Sent...");
        
        [_manager POST:url parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [self url_success:promise :responseObject :url];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            [self url_failure:promise :error :url];
        }];
        
    }
    
    
    return promise;
}

////
// Callback: on success response
//
- (void)url_success:(RXPromise *)promise :(NSObject *)data :(NSString *)url
{
    NSLog(@"...Comlpeted Request...");
    [promise fulfillWithValue:data];
}

////
// Callback: on failed response
//
- (void)url_failure:(RXPromise *)promise :(NSError *)error :(NSString *)url
{
    [promise rejectWithReason:error];
}



#pragma mark - Public - Update Request Headers

////
// Update Shuttle Request headers
//
- (void)updateHeaders:(NSDictionary *)defaults
{
    for (NSString *key in defaults) {
        [[_manager requestSerializer] setValue:[defaults valueForKey:key]  forHTTPHeaderField:key];
    }
}



#pragma mark - Private - TESTING - Method Swizzling

////
// Active `MockRequests` for testing - http://nshipster.com/method-swizzling/
//
- (void)activateMockRequests
{
    if (!_mockRequests) {
        _mockRequests = [ShuttleMockRequests new];
        [_mockRequests enableMockShuttleRequests];
    }
    
    [Shuttle class_activateMockRequests];
}

+ (void)class_activateMockRequests
{
    SEL originalSelector = @selector(launch::::);
    SEL swizzledSelector = @selector(fakeLaunch::::);
    
    Method originalMethod = class_getInstanceMethod([self class], originalSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

////
// Deactivate `MockRequests` after testing
//
- (void)deactivateMockRequests
{
    [_mockRequests disableMockShuttleRequests];
    _mockRequests = nil;
    [Shuttle class_deactivateMockRequests];
}

+ (void)class_deactivateMockRequests
{
    SEL originalSelector = @selector(launch::::);
    SEL swizzledSelector = @selector(fakeLaunch::::);
    
    Method originalMethod = class_getInstanceMethod([self class], originalSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    
    method_exchangeImplementations(swizzledMethod, originalMethod);
}

////
// `Fake Launch` method - return dummy responses
//
- (RXPromise *)fakeLaunch:(ShuttleModes)mode :(ShuttleResponses)response :(NSString *)url :(NSDictionary *)params
{
    if ([[params allKeys] count] == 0) {
        NSLog(@"===> Fake Launch: %@", url);
    } else {
        NSLog(@"===> Fake Launch: %@ - with params: %@", url, params);
    }
    
    if ([_mockRequests requestTimeout] == YES) {
        NSLog(@"===> Fake Launch - Timeout...");
        return [self fakeLaunchAndTimeout];
    }
    
    RXPromise *promise = [RXPromise new];
    
    NSObject *mockResponse = [_mockRequests checkRequestReturnResponse:url];
    
    if ([mockResponse isKindOfClass:[NSError class]]) {
        [promise rejectWithReason:mockResponse];
    } else {
        [promise fulfillWithValue:mockResponse];
    }
    
    return promise;
}

////
// `Fake Launch` method - sleeps thread for (5) seconds then returns error
//
- (RXPromise *)fakeLaunchAndTimeout
{
    RXPromise *timeoutPromise = [RXPromise new];
    sleep(5);
    [self url_failure:timeoutPromise :[NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey:@"Timeout"}] :@""];
    return timeoutPromise;
}

////
// 'Bridge' method for adding URL's to MockRequests
//
- (void)ifURLMatches:(NSString *)requestURL thenReturn:(NSObject *)response
{
    [_mockRequests ifURLMatches:requestURL thenReturn:response];
}

////
// Check for matching request parts - return appropriate testing response
//
- (void)ifURLContains:(NSArray *)parts thenReturn:(NSObject *)response
{
    [_mockRequests ifURLContains:parts thenReturn:response];
}

////
// 'Bridge' method for adding URL's to MockRequests
//
- (void)ifURLMatchesTimeout:(NSString *)requestURL
{
    [_mockRequests setRequestTimeout:YES];
    [_mockRequests ifURLMatches:requestURL thenReturn:@{}];
}

////
// Check for matching request parts - return appropriate testing response
//
- (void)ifURLContainsTimeout:(NSArray *)parts
{
    [_mockRequests setRequestTimeout:YES];
    [_mockRequests ifURLContains:parts thenReturn:@{}];
}

////
// Read JSON file, convert to NSDictionary
//
- (NSDictionary *)JSONFromFile:(NSString *)filename
{
    NSString *filepath = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error reading file: %@", error.localizedDescription);
        return @{};
    }
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[fileContents dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
        NSLog(@"Error reading file: %@", error.localizedDescription);
        return @{};
    }
    
    return dict;
}

@end
