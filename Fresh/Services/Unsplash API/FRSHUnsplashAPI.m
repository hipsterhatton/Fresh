//
//  FRSHUnsplashAPI.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FRSHUnsplashAPI.h"

#define UNSPLASH_API_KEY     @"a337f950a2a232bc8c8a6f3bac2a0697dc731eb66b2745bebd0ad67dad54f9ec"
#define UNSPLASH_RELATED_THRESHOLD  200
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



#pragma mark - Public - Image/Collection Methods

////
// Return URL of a random wallpaper from collection(s)
//
- (RXPromise *)getWallpaperURLForScreen:(FRSHScreen *)screen
{
    [[screen state] setObject:@"start: get Unsplash wallpaper URL" forKey:@"status"];
    
    return [self.shuttle launch:GET :JSON :[self constructWallpaperURL:screen] :nil]
    
    .then(^id (NSDictionary *rawJSON) {
        [[screen state] setObject:@"done: get Unsplash wallpaper URL" forKey:@"status"];
        return @{@"id" : rawJSON[@"id"], @"url" : rawJSON[@"urls"][@"custom"]};
    }, nil)
    
    .then(^id (NSDictionary *data) {
        [[screen state] setObject:data[@"url"] forKey:@"wallpaper_url"];
        return data;
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        return error;
    });
}

////
// Search for collections via keyword
//
- (RXPromise *)searchCollections:(NSString *)searchTerm pageNumber:(int)pageNumber
{
    NSString *url = @"https://api.unsplash.com/search/collections?page=#{PageNumber}&client_id=#{ClientID}&query=#{Term}";
    
    NSArray *placeholders = @[ @"#{ClientID}", @"#{PageNumber}", @"#{Term}" ];
    NSArray *values =       @[ UNSPLASH_API_KEY, i_to_s(pageNumber), searchTerm ];
    
    url = [self _replace:url :placeholders :values];
    
    __block NSMutableDictionary *_results = [NSMutableDictionary new];
    
    return [self.shuttle launch:GET :JSON :url :nil]
    
    .then(^id (NSDictionary *rawJSON) {
        _results[@"number_of_results"] = @([rawJSON[@"total"] intValue]);
        return rawJSON;
    }, nil)
    
    .then(^id (NSDictionary *rawJSON) {
        _results[@"collections"] = [NSMutableArray new];
        
        for (int _a = 0; _a < [rawJSON[@"results"] count]; _a++) {
            NSDictionary *_d = rawJSON[@"results"][_a];
            
            NSMutableArray *_previewPhotos = [NSMutableArray new];
            for (int _b = 0; _b < [_d[@"preview_photos"] count]; _b++) {
                
                [_previewPhotos addObject:rawJSON[@"results"][_a][@"preview_photos"][_b][@"urls"][@"thumb"]];
            }
            
            [_results[@"collections"] addObject:@{
                                                  @"id" :   rawJSON[@"results"][_a][@"id"],
                                                  @"sample_images" : _previewPhotos,
                                                  @"fetch_related" : @(([rawJSON[@"results"][_a][@"total_photos"] intValue] < UNSPLASH_RELATED_THRESHOLD ? YES : NO))
                                                  }];
        }
        return _results;
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        return error;
    });
}

////
// Get releated collection ID's for a collection
//
- (RXPromise *)getRelatedCollectionIDsForCollectionID:(NSString *)collectionID
{
    NSString *url = @"https://api.unsplash.com/collections/#{CollectionID}/related?client_id=#{ClientID}";
    
    NSArray *placeholders = @[ @"#{ClientID}", @"#{CollectionID}" ];
    NSArray *values =       @[ UNSPLASH_API_KEY, collectionID ];
    
    url = [self _replace:url :placeholders :values];
    
    __block NSMutableArray *_results = [NSMutableArray new];
    
    return [self.shuttle launch:GET :JSON :url :nil]
    
    .then(^id (NSArray *rawJSON) {
        for (int _a = 0; _a < [rawJSON count]; _a++) {
            [_results addObject:rawJSON[_a][@"id"]];
        }
        return _results;
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        return error;
    });
}

////
// Get releated collection ID's for a collection
//
- (RXPromise *)searchPhotos:(NSString *)searchTerm pageNumber:(int)pageNumber
{
    NSString *url = @"https://api.unsplash.com/search/photos?query=#{SearchTerm}&client_id=#{ClientID}";
    
    NSArray *placeholders = @[ @"#{ClientID}", @"#{SearchTerm}" ];
    NSArray *values =       @[ UNSPLASH_API_KEY, searchTerm ];
    
    url = [self _replace:url :placeholders :values];
    
    __block NSMutableArray *_results = [NSMutableArray new];
    
    return [self.shuttle launch:GET :JSON :url :nil]
    
    .then(^id (NSDictionary *rawJSON) {
        for (int _a = 0; _a < [rawJSON[@"results"] count]; _a++) {
            [_results addObject:@{
                                  @"id" :   rawJSON[@"results"][_a][@"id"],
                                  @"url" :  rawJSON[@"results"][_a][@"urls"][@"full"]
                                  }];
        }
        return _results;
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        return error;
    });
}

////
// Get download URL for a specific image (takes: imageID)
//
- (void)getWallpaperURLForScreen:(FRSHScreen *)screen withImageID:(NSString *)imageID withImageURL:(NSString *)imageURL
{
    [[screen state] setObject:@"start: get Unsplash wallpaper URL" forKey:@"status"];
    
    int _width = [[screen getScreenDimensions][@"width"] intValue];
    int _height = [[screen getScreenDimensions][@"height"] intValue];
    
    NSString *url = @"#{ImageURL}?client_id=#{ClientID}&w=#{Width}&h=#{Height}";
    
    NSArray *placeholders = @[ @"#{ClientID}", @"#{ImageURL}", @"#{Width}", @"#{Height}" ];
    NSArray *values =       @[ UNSPLASH_API_KEY, imageURL, i_to_s(_width), i_to_s(_height) ];
    
    url = [self _replace:url :placeholders :values];
    
    [[screen state] setObject:@"done: get Unsplash wallpaper URL" forKey:@"status"];
    
    [[screen state] setObject:imageID forKey:@"wallpaper_id"];
    [[screen state] setObject:url forKey:@"wallpaper_url"];
}



#pragma mark - Private - Generic Methods

- (NSString *)constructWallpaperURL:(FRSHScreen *)screen
{
    int _width = [[screen getScreenDimensions][@"width"] intValue];
    int _height = [[screen getScreenDimensions][@"height"] intValue];
    NSString *_collections = [[screen getScreenCollections] componentsJoinedByString:@","];
    
    NSString *url = @"https://api.unsplash.com/photos/random?client_id=#{ClientID}&orientation=landscape&collections=#{Collections}&w=#{Width}&h=#{Height}";
    
    NSArray *placeholders = @[ @"#{ClientID}", @"#{Collections}", @"#{Width}", @"#{Height}" ];
    NSArray *values =       @[ UNSPLASH_API_KEY, _collections, i_to_s(_width), i_to_s(_height) ];
    
    return [self _replace:url :placeholders :values];
}

- (RXPromise *)getPhotosFromCollection:(NSString *)collectionID
{
    NSString *url = @"https://api.unsplash.com/collections/#{CollectionID}/photos?#{ClientID}&per_page=5";
    
    NSArray *placeholders = @[ @"#{ClientID}", @"#{CollectionID}" ];
    NSArray *values =       @[ UNSPLASH_API_KEY, collectionID ];
    
    url = [self _replace:url :placeholders :values];
    
    __block NSMutableArray *_results = [NSMutableArray new];
    
    return [self.shuttle launch:GET :JSON :url :nil]
    
    .then(^id (NSArray *rawJSON) {
        for (int _a = 0; _a < [rawJSON count]; _a++) {
            [_results addObject:rawJSON[_a][@"urls"][@"thumb"]];
        }
        
        return _results;
    }, nil)
    
    .then(nil, ^id(NSError *error) {
        return error;
    });
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
