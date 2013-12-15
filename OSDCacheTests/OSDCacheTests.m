//
//  OSDCacheTests.m
//  OSDCacheTests
//
//  Created by Skylar Schipper on 12/15/13.
//  Copyright (c) 2013 OpenSky, LLC. All rights reserved.
//

#import "OSDCacheTestCase.h"

@interface OSDCacheTests : OSDCacheTestCase

@end

@implementation OSDCacheTests

- (void)testCacheSingletons {
    XCTAssertNotNil([OSDCache diskCache]);
    XCTAssertTrue([[OSDCache diskCache] isKindOfClass:NSClassFromString(@"OSDDiskCache")]);
    
    XCTAssertNotNil([OSDCache memCache]);
    XCTAssertTrue([[OSDCache memCache] isKindOfClass:NSClassFromString(@"OSDMemCache")]);
    
    XCTAssertNotNil([OSDCache tmpCache]);
    XCTAssertTrue([[OSDCache tmpCache] isKindOfClass:NSClassFromString(@"OSDTmpCache")]);
}
- (void)testOverrideMethods {
    OSDCache *cache = [[OSDCache alloc] init];
    XCTAssertThrowsSpecificNamed([cache clear], NSException, OSDCacheException);
    XCTAssertThrowsSpecificNamed([cache read:nil], NSException, OSDCacheException);
    XCTAssertThrowsSpecificNamed([cache write:nil keys:nil], NSException, OSDCacheException);
    XCTAssertThrowsSpecificNamed([cache deleteWithKeys:nil error:NULL], NSException, OSDCacheException);
}
- (void)testCachePath {
    NSString *baseCachePath = [[OSDCache diskCache] baseCachePath];
    XCTAssertNotNil(baseCachePath);
    
    NSString *path = [baseCachePath stringByAppendingPathComponent:@"OSDCache/1.0"];
    XCTAssertEqualObjects([[OSDCache diskCache] cachePath], path);
}
- (void)testCacheKeyPath {
    NSArray *keys = @[
                      @"one",
                      @"two",
                      @"three"
                      ];
    NSString *diskPath = [[OSDCache diskCache] keyPathForKeys:keys];
    NSString *memPath = [[OSDCache memCache] keyPathForKeys:keys];
    NSString *tmpPath = [[OSDCache tmpCache] keyPathForKeys:keys];
    
    XCTAssertEqualObjects(diskPath, memPath);
    XCTAssertEqualObjects(diskPath, tmpPath);
    
    XCTAssertEqualObjects(memPath, diskPath);
    XCTAssertEqualObjects(memPath, tmpPath);
    
    XCTAssertEqualObjects(tmpPath, diskPath);
    XCTAssertEqualObjects(tmpPath, memPath);
    
    XCTAssertEqualObjects(diskPath, @"one_two_three");
    XCTAssertEqualObjects(tmpPath, @"one_two_three");
    XCTAssertEqualObjects(memPath, @"one_two_three");
}


@end
