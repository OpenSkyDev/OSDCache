/*!
*  OSDTmpCacheTests.m
*  OSDCache
*
*  Created by Skylar Schipper on 12/15/13.
*    Copyright (c) 2013 OpenSky, LLC. All rights reserved.
*/

#import "OSDCacheTestCase.h"

@interface OSDTmpCacheTests : OSDCacheTestCase

@end

@implementation OSDTmpCacheTests

- (void)testTempCacheReadWrite {
    NSDictionary *cache = @{
                            @"id": @32901,
                            @"name": @"Test Name"
                            };
    NSUInteger __block count = 0;
    NSData *data = [[OSDCache tmpCache] read:@[@"test",@"info",@"disk"] perform:^id{
        count++;
        return [NSJSONSerialization dataWithJSONObject:cache options:0 error:nil];
    }];
    
    XCTAssertTrue(count == 1);
    
    NSData *data2 = [[OSDCache tmpCache] read:@[@"test",@"info",@"disk"] perform:^id{
        count++;
        return [NSJSONSerialization dataWithJSONObject:cache options:0 error:nil];
    }];
    
    XCTAssertTrue(count == 1);
    
    XCTAssertEqualObjects(data, data2);
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
    XCTAssertEqualObjects(cache[@"id"], JSON[@"id"]);
    XCTAssertEqualObjects(cache[@"name"], JSON[@"name"]);
}

@end
