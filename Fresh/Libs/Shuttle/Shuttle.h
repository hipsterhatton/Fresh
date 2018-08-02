//
//  Shuttle.h
//  Shuttle
//
//  Created by Stephen Hatton on 08/04/2015.
//  Copyright (c) 2015 Stephen Hatton. All rights reserved.
//

#import <objc/runtime.h>

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <RXPromise/RXPromise.h>

#import "ShuttleMockRequests.h"
#import "Reachability.h"

@interface Shuttle : NSObject

typedef enum {
    GET,
    POST
} ShuttleModes;

typedef enum {
    HTTP,
    JSON,
    Image
} ShuttleResponses;

typedef enum {
    Wifi,
    WAN,
    None,
    Unknown
} ShuttleConnection;

@property (nonatomic, retain) ShuttleMockRequests *mockRequests;

@property (nonatomic, retain) AFHTTPSessionManager *manager;

@property (nonatomic, retain) AFHTTPResponseSerializer *HTTPResponse;
@property (nonatomic, retain) AFJSONResponseSerializer *JSONResponse;
@property (nonatomic, retain) AFImageResponseSerializer *IMGResponse;

@property (nonatomic) int numberOfBackToBackRequests;
@property (nonatomic) ShuttleConnection connectionType;


- (id)initWithDefaults:(NSDictionary *)defaults;
- (void)updateHeaders:(NSDictionary *)defaults;
- (RXPromise *)launch:(ShuttleModes)mode :(ShuttleResponses)response :(NSString *)url :(NSDictionary *)params;


// Shuttle Mock Requests - Testing Methods
- (void)activateMockRequests;
- (void)deactivateMockRequests;

- (void)ifURLMatches:(NSString *)requestURL thenReturn:(NSObject *)response;
- (void)ifURLContains:(NSArray *)parts thenReturn:(NSObject *)response;

- (NSDictionary *)JSONFromFile:(NSString *)filename;

@end
