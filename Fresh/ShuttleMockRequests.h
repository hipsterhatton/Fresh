//
//  ShuttleMockRequests.h
//  Fresh
//
//  Created by Stephen Hatton on 02/11/2017.
//  Copyright © 2017 Stephen Hatton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShuttleMockRequests : NSObject

@property (nonatomic) BOOL active;
@property (nonatomic, retain) NSMutableDictionary *mockRequests;
@property (nonatomic) BOOL requestTimeout;


- (void)enableMockShuttleRequests;
- (void)disableMockShuttleRequests;

- (void)ifURLMatches:(NSString *)requestURL thenReturn:(NSObject *)response;
- (void)ifURLContains:(NSArray *)parts thenReturn:(NSObject *)response;

- (NSObject *)checkRequestReturnResponse:(NSString *)request;

@end
