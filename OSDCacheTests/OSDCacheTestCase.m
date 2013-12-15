/*!
 * OSDCacheTestCase.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 12/15/13
 */

#import "OSDCacheTestCase.h"

@interface OSDCacheTestCase ()

@end

@implementation OSDCacheTestCase

+ (void)tearDown {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [[OSDCache class] performSelector:NSSelectorFromString(@"resetCacheFromTests")];
#pragma clang diagnostic pop
    
    [super tearDown];
}

@end
