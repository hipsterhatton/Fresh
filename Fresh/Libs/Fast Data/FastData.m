//
//  FastData.m
//  Fresh
//
//  Created by Stephen Hatton on 09/01/2019.
//  Copyright © 2019 Stephen Hatton. All rights reserved.
//

#import "FastData.h"

@implementation FastData

static dispatch_once_t onceToken;

#pragma mark - Init Methods

+ (id)sharedInstance
{
    static FastData *fastData = nil;
    dispatch_once(&onceToken, ^{
        fastData = [[self alloc] init];
    });
    return fastData;
}

- (id)init
{
    if (self = [super init]) {
    }
    
    return self;
}


////
// Write data
//
- (void)writeData:(NSObject *)dataToWrite key:(NSString *)key, ...
{
    va_list args;
    va_start(args, key);
    
    // Turn va_list of `keys` into an array
    
    NSMutableArray *_keys = [@[] mutableCopy];
    for (NSString *arg = key; arg != nil; arg = va_arg(args, NSString *)) {
        [_keys addObject:arg];
    }
    
    NSMutableDictionary *_md = [[GVUserDefaults standardUserDefaults].data mutableDeepCopy];
    [self buildUpData: _md dataToWrite:dataToWrite keys:_keys counter:0];
    [GVUserDefaults standardUserDefaults].data = _md;
}

- (void)buildUpData:(NSMutableDictionary *)_mutableFastData dataToWrite:(NSObject *)dataToWrite keys:(NSArray *)_keys counter:(int)_a
{
    NSString *_objectClass;
    NSArray *_objectClassAllowed = @[@"__NSDictionaryM", @"__NSCFDictionary"];
    
    // Check if the dictionary has a value for _keys[_a]
    // YES: then check the type of this object (change to dictionary if needs be) then: _mfd = _mfd[key]
    // NO:  then create a dictionary then: _mfd = _mfd[key]
    
    if (_mutableFastData[_keys[_a]]) {
        
        NSLog(@"1. Fast Data has key: %@", _keys[_a]);
        
        _objectClass = [NSString stringWithFormat:@"%@", [_mutableFastData[_keys[_a]] class]];
        
        if (![_objectClassAllowed containsObject:_objectClass]) {
            NSLog(@"2. Fast Data value for key: %@ IS NOT A DICT", _keys[_a]);
            [_mutableFastData setValue:[@{} mutableCopy] forKey:_keys[_a]];
        } else {
            NSLog(@"2. Fast Data value for key: %@ was ok", _keys[_a]);
        }
        
    } else {
        NSLog(@"1. Fast Data DOES NOT have key: %@", _keys[_a]);
        [_mutableFastData setValue:[@{} mutableCopy] forKey:_keys[_a]];
    }
    
    if (_a == ([_keys count] - 1)) {
        NSLog(@"Breaking loop...");
        [_mutableFastData setValue:dataToWrite forKey:_keys[_a]];
        return;
    } else {
        [self buildUpData:_mutableFastData[_keys[_a]] dataToWrite:dataToWrite keys:_keys counter:(_a+=1)];
    }
}


////
// Read data
//
- (NSObject *)readData:(NSString *)key, ...
{
    va_list args;
    va_start(args, key);
    
    NSMutableArray *_keys = [@[] mutableCopy];
    for (NSString *arg = key; arg != nil; arg = va_arg(args, NSString *)) {
        [_keys addObject:arg];
    }
    
    NSDictionary *_d = [GVUserDefaults standardUserDefaults].data;
    
    for (int _a = 0; _a < [_keys count]; _a++) {
        if (_d[_keys[_a]] && _a == ([_keys count] - 1)) {
            return _d[_keys[_a]];
        } else if (_d[_keys[_a]] && _a != ([_keys count] - 1)) {
            _d = _d[_keys[_a]];
        } else {
            return nil;
        }
    }
    
    return nil;
}


////
// Purge data
//
- (void)purgeData:(NSString *)key, ...
{
    if (!key) {
        [GVUserDefaults standardUserDefaults].data = @{};
        return;
    }
    
    va_list args;
    va_start(args, key);
    
    NSMutableArray *_keys = [@[] mutableCopy];
    for (NSString *arg = key; arg != nil; arg = va_arg(args, NSString *)) {
        [_keys addObject:arg];
    }
    
    NSMutableDictionary *_md = [[GVUserDefaults standardUserDefaults].data mutableDeepCopy];
    [self findAndRemoveData:_md dataToWrite:nil keys:_keys counter:0];
    [GVUserDefaults standardUserDefaults].data = _md;
}

- (void)findAndRemoveData:(NSMutableDictionary *)_mutableFastData dataToWrite:(NSObject *)dataToWrite keys:(NSArray *)_keys counter:(int)_a
{
    if (_mutableFastData[_keys[_a]] && _a != ([_keys count] - 1)) {
        [self findAndRemoveData:_mutableFastData[_keys[_a]] dataToWrite:nil keys:_keys counter:(_a+=1)];
        
    } else if (_mutableFastData[_keys[_a]] && _a == ([_keys count] - 1)) {
        [_mutableFastData removeObjectForKey:_keys[_a]];
        return;
        
    } else {
        return;
    }
}

////
// Return [GVUserDefaults].data
//
- (NSDictionary *)getData
{
    return [GVUserDefaults standardUserDefaults].data;
}

@end
