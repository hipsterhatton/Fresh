//
//  ShuttleMockRequests.m
//  Fresh
//
//  Created by Stephen Hatton on 02/11/2017.
//  Copyright © 2017 Stephen Hatton. All rights reserved.
//

#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#import "ShuttleMockRequests.h"

@implementation ShuttleMockRequests

#pragma mark - Public - Enable/Disable Mock Requests

////
// Catch requests - return mock responses
//
- (void)enableMockShuttleRequests
{
    _active = true;
    
    if (!_mockRequests) {
        _mockRequests = [@{
                           @"url_matches" : [@{} mutableCopy],
                           @"url_contains" : [@[] mutableCopy]
                           } mutableCopy];
    }
}

////
// Stop catching requests
//
- (void)disableMockShuttleRequests
{
    _active = false;
    _mockRequests = nil;
}



#pragma mark - Public - Add Requst Pattern

////
// Check for matching request - return appropriate testing response
//
- (void)ifURLMatches:(NSString *)requestURL thenReturn:(NSObject *)response
{
    [_mockRequests[@"url_matches"] setObject:response forKey:requestURL];
}

////
// Check for matching request parts - return appropriate testing response
//
- (void)ifURLContains:(NSArray *)parts thenReturn:(NSObject *)response
{
    NSDictionary *_d = @{
                         @"parts" : parts,
                         @"response" : response
                         };
    [[_mockRequests objectForKey:@"url_contains"] addObject:_d];
}



#pragma mark - Public - Call Catching

////
// Check the request, return the matching response (XML, JSON, NSError)
//
- (NSObject *)checkRequestReturnResponse:(NSString *)request
{
    // Check if the response has an exact match...
    NSObject *exactMatchResponse = _mockRequests[@"url_matches"][request];
    
    if (exactMatchResponse) {
        return exactMatchResponse;
    }
    
    // Check if we have any approximate matches...
    NSString *_urlPiece;
    BOOL _skip = false;
    
    // Iterate: array of @{part, response}
    for (int _a = 0; _a < [_mockRequests[@"url_contains"] count]; _a++) {
        
        int part_array_count = (int)[_mockRequests[@"url_contains"][_a][@"part"] count];
        
        // Iterate each: @{part: array}
        for (int _b = 0; _b < part_array_count; _b++) {
            
            _urlPiece = _mockRequests[@"url_contains"][_a][@"part"][_b];
            
            if (![request containsString:_urlPiece]) {
                _skip = true;
                break;
            }
        }
        
        if (_skip) {
            continue;
        } else {
            return _mockRequests[@"url_contains"][_a][@"response"];
        }
    }
    
    return nil;
}

@end
