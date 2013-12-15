/*!
*  OSDMemCacheTests.m
*  OSDCache
*
*  Created by Skylar Schipper on 12/15/13.
*    Copyright (c) 2013 OpenSky, LLC. All rights reserved.
*/

#import "OSDCacheTestCase.h"

@interface OSDMemCacheTests : OSDCacheTestCase

@end

@implementation OSDMemCacheTests

- (void)testCacheRead {
    NSArray *keys = @[@"cache",@"read",@"test"];
    NSUInteger __block count = 0;
    NSString *value = [[OSDCache memCache] read:keys perform:^id{
        count++;
        return @"Cache Value";
    }];
    XCTAssertEqualObjects(value, @"Cache Value");
    NSString *value2 = [[OSDCache memCache] read:keys perform:^id{
        count++;
        return @"Cache Value";
    }];
    XCTAssertEqualObjects(value2, @"Cache Value");
    
    XCTAssertTrue(count == 1);
}

@end
