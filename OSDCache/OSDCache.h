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

/*!
 *  A simple object cache that supports 3 different cache types.
 *
 *  - The disk cache saves NSData objects to the disk.  Objects persist through relaunches
 *  - The tmp disk cache saves NSData objects to the disk.  Objects are cleared on app termination
 *  - The memory cache saves any object into an in memory cache.  The cache is cleared on termination, or memory pressure.
 */
@interface OSDCache : NSObject

/*!
 *  Shared disk cache.  This saves items to the iPhone Caches directory.  They will persist through an application relaunch.
 *
 *  \return The shared disk cache instance.
 */
+ (instancetype)diskCache;
/*!
 *  Shared memory cache.  This will be cleared on memory pressure, or app termination.
 *
 *  \return The shared memory cache instance.
 */
+ (instancetype)memCache;
/*!
 *  Shared tmp disk cache.  This acts the same as the disk cache, except the file cache will be cleared on app termination.
 *
 *  \return The shared tmp disk cache instance.
 */
+ (instancetype)tmpCache;

#pragma mark -
#pragma mark - Cache Management
/*!
 *  Clears the cached objects.
 */
- (void)clear;

#pragma mark -
#pragma mark - Helpers
- (NSString *)baseCachePath;
- (NSString *)cachePath;

- (BOOL)createCacheDirectoryIfNeeded:(NSError **)error;

- (NSString *)versionNumberString;

#pragma mark -
#pragma mark - Cache Methods
/*!
 *  Reads objects from the cache.
 *
 *  \param keys An NSArray of NSString used to construct the key path.
 *
 *  \return The cached object
 */
- (id)read:(NSArray *)keys;
/*!
 *  Reads objects from the cache.
 *
 *  \param keys    An NSArray of NSString used to construct the key path.
 *  \param perform The block to get the value if it doesn't exist in the cache.  This can't be nil.
 *
 *  \return The cached object
 */
- (id)read:(NSArray *)keys perform:(id(^)(void))perform;

/*!
 *  Write the object into the cache
 *
 *  \param value The value to write
 *  \param keys  An NSArray of NSString used to construct the key path.
 *
 *  \return A success indicator.
 */
- (BOOL)write:(id)value keys:(NSArray *)keys;
/*!
 *  Write the object into the cache
 *
 *  \param value The value to write
 *  \param keys  An NSArray of NSString used to construct the key path.
 *  \param error An error pointer or NULL
 *
 *  \return A success indicator.
 */
- (BOOL)write:(id)value keys:(NSArray *)keys error:(NSError **)error;

/*!
 *  Delete the item from the cache
 *
 *  \param keys An NSArray of NSString used to construct the key path.
 *
 *  \return A success indicator
 */
- (BOOL)deleteWithKeys:(NSArray *)keys;
/*!
 *  Delete the item from the cache
 *
 *  \param keys  An NSArray of NSString used to construct the key path.
 *  \param error An error pointer or NULL
 *
 *  \return A success indicator
 */
- (BOOL)deleteWithKeys:(NSArray *)keys error:(NSError **)error;

/*!
 *  Turns the keys array into the key path
 *
 *  \param keys An NSArray of NSString used to construct the key path.
 *
 *  \return The NSString from the cache keys
 */
- (NSString *)keyPathForKeys:(NSArray *)keys;
- (NSString *)filePathForKey:(NSString *)key;

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

#pragma mark -
#pragma mark - File Path Helpers
- (void)registerFileExtentions:(NSArray *)fileExtentions;

@end

OBJC_EXTERN NSString * const OSDCacheException;

OBJC_EXTERN NSString * const OSDCacheErrorDomain;
typedef NS_ENUM(NSInteger, OSDCacheErrors) {
    OSDCacheErrorUnknown = -1
};

#endif
