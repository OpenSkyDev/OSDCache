/*!
 * OSDCache.h
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 12/15/13
 */

#ifndef OSDCache_h
#define OSDCache_h

@import Foundation;

#define OSDCacheVersion_1_0 1000.0
OBJC_EXTERN float_t const OSDCacheVersionNumber;

@interface OSDCache : NSObject

+ (instancetype)diskCache;
+ (instancetype)memCache;
+ (instancetype)tmpCache;

#pragma mark -
#pragma mark - Cache Management
- (void)clear;

#pragma mark -
#pragma mark - Helpers
- (NSString *)baseCachePath;
- (NSString *)cachePath;

- (BOOL)createCacheDirectoryIfNeeded:(NSError **)error;

- (NSString *)versionNumberString;

#pragma mark -
#pragma mark - Cache Methods
- (id)read:(NSArray *)keys;
- (id)read:(NSArray *)keys perform:(id(^)(void))perform;

- (BOOL)write:(id)value keys:(NSArray *)keys;
- (BOOL)write:(id)value keys:(NSArray *)keys error:(NSError **)error;

- (BOOL)deleteWithKeys:(NSArray *)keys;
- (BOOL)deleteWithKeys:(NSArray *)keys error:(NSError **)error;

- (NSString *)keyPathForKeys:(NSArray *)keys;

#pragma mark -
#pragma mark - Metadata
- (void)countObjectsInCache:(void(^)(NSUInteger count))cache;
- (NSUInteger)objectsInCache;

#pragma mark -
#pragma mark - Subclass Hooks
- (id)performReadForKey:(NSString *)key;
- (BOOL)performWrite:(id)write forKey:(NSString *)key error:(NSError **)error;
- (BOOL)performDeleteWithKey:(NSString *)key error:(NSError **)error;
- (void)performCacheClear;

@end

OBJC_EXTERN NSString * const OSDCacheException;

OBJC_EXTERN NSString * const OSDCacheErrorDomain;
typedef NS_ENUM(NSInteger, OSDCacheErrors) {
    OSDCacheErrorUnknown = -1
};

#endif
