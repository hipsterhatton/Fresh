//
//  FRSHUnsplashAPI.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FRSHUnsplashAPI.h"

#define UNSPLASH_API_KEY     @"a337f950a2a232bc8c8a6f3bac2a0697dc731eb66b2745bebd0ad67dad54f9ec"
#define i_to_s(i)   [NSString stringWithFormat:@"%d", i]

@implementation FRSHUnsplashAPI

- (id)init
{
    if (self = [super init]) {
        _shuttle = [[Shuttle alloc] initWithDefaults:@{
                                                       @"Accept-Version" : @"v1"
                                                       }];
    }
    return self;
}

////
// Return URL of a random wallpaper from collection(s)
//
- (RXPromise *)getWallpaperURLForScreen:(FRSHScreen *)screen
{
    [[screen state] setObject:@"about to fetch unsplash url" forKey:@"status"];
    
    return [self.shuttle launch:GET :JSON :[self constructWallpaperURL:screen] :nil]
    
    .then(^id (NSDictionary *rawJSON) {
        [[screen state] setObject:@"got custom url" forKey:@"status"];
        return @{@"id" : rawJSON[@"id"], @"url" : rawJSON[@"urls"][@"custom"]};
    }, nil)
    
    .then(^id (NSDictionary *data) {
        [[screen state] setObject:data[@"url"] forKey:@"wallpaper_url"];
        return data;
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return error;
    });
}

- (NSString *)constructWallpaperURL:(FRSHScreen *)screen
{
    int _width = [[screen getScreenDimensions][@"width"] intValue];
    int _height = [[screen getScreenDimensions][@"height"] intValue];
    NSString *_collections = [[self getDefaultCollection] componentsJoinedByString:@","];
    
    NSString *url = @"https://api.unsplash.com/photos/random?client_id=#{ClientID}&orientation=landscape&collections=#{Collections}&w=#{Width}&h=#{Height}";
    
    NSArray *placeholders = @[ @"#{ClientID}", @"#{Collections}", @"#{Width}", @"#{Height}" ];
    NSArray *values =       @[ UNSPLASH_API_KEY, _collections, i_to_s(_width), i_to_s(_height) ];
    
    return [self _replace:url :placeholders :values];
}

- (NSArray *)getDefaultCollection
{
    return @[
             @"220388"
             ];
}

- (NSString *)_replace:(NSString *)string :(NSArray *)placeholders :(NSArray *)values
{
    if ([placeholders count] != [values count]) {
        NSLog(@" ---[Wrong amount of Placeholders and Values] - API");
        return nil;
    }
    
    for (int a = 0; a < [values count]; a++) {
        string = [string stringByReplacingOccurrencesOfString:placeholders[a] withString:values[a]];
    }
    
    return string;
}

@end
