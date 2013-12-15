/*!
 * OSDCache.m
 *
 * Copyright (c) 2013 OpenSky, LLC
 *
 * Created by Skylar Schipper on 12/15/13
 */

#import "OSDCache.h"

static id _OSDCache_Disk = nil;
static id _OSDCache_Mem  = nil;
static id _OSDCache_Tmp  = nil;

@interface OSDDiskCache : OSDCache

@end
@interface OSDMemCache : OSDCache

@end
@interface OSDTmpCache : OSDDiskCache

@end

@interface OSDCache ()

@property (nonatomic, strong) NSCache *tempMemCache;

@end

@implementation OSDCache

+ (instancetype)diskCache {
    @synchronized (self) {
        if (!_OSDCache_Disk) {
            _OSDCache_Disk = [[OSDDiskCache alloc] init];
        }
        return _OSDCache_Disk;
    }
}
+ (instancetype)memCache {
    @synchronized (self) {
        if (!_OSDCache_Mem) {
            _OSDCache_Mem = [[OSDMemCache alloc] init];
        }
        return _OSDCache_Mem;
    }
}
+ (instancetype)tmpCache {
    @synchronized (self) {
        if (!_OSDCache_Tmp) {
            _OSDCache_Tmp = [[OSDTmpCache alloc] init];
        }
        return _OSDCache_Tmp;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSError *createPathError = nil;
        if (![self createCacheDirectoryIfNeeded:&createPathError]) {
            NSLog(@"Can't create path: %@",createPathError);
        }
    }
    return self;
}

+ (void)resetCacheFromTests {
    [_OSDCache_Disk clear];
    [_OSDCache_Mem clear];
    [_OSDCache_Tmp clear];
    _OSDCache_Disk = nil;
    _OSDCache_Mem = nil;
    _OSDCache_Tmp = nil;
}

#pragma mark -
#pragma mark - Lazy Loaders
- (NSCache *)tempMemCache {
    if (!_tempMemCache) {
        _tempMemCache = [[NSCache alloc] init];
    }
    return _tempMemCache;
}

#pragma mark -
#pragma mark - Cache Management
- (void)clear {
    [self.tempMemCache removeAllObjects];
    [self performCacheClear];
}

#pragma mark -
#pragma mark - Helpers
- (NSString *)baseCachePath {
    static NSString *cacheBasePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheBasePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    });
    return cacheBasePath;
}
- (NSString *)cachePath {
    static NSString *cachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *base = [self baseCachePath];
        if (!base) {
            cachePath = nil;
        } else {
            cachePath = [[base stringByAppendingPathComponent:@"OSDCache"] stringByAppendingPathComponent:[self versionNumberString]];
        }
    });
    return cachePath;
}
- (BOOL)createCacheDirectoryIfNeeded:(NSError **)error {
    NSString *cachePath = [self cachePath];
    if (!cachePath) {
        return YES;
    }
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir]) {
        if (!isDir) {
            @throw [NSException exceptionWithName:OSDCacheException reason:[NSString stringWithFormat:@"%@ is not a directory",cachePath] userInfo:nil];
        }
        return YES;
    }
    return [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:error];
}

- (NSString *)versionNumberString {
    if (OSDCacheVersionNumber <= OSDCacheVersion_1_0) {
        return @"1.0";
    }
    return @"";
}

#pragma mark -
#pragma mark - Cache Methods
- (id)read:(NSArray *)keys {
    NSString *key = [self keyPathForKeys:keys];
    id value = [self.tempMemCache objectForKey:key];
    if (value) {
        return value;
    }
    value = [self performReadForKey:key];
    if (value) {
        [self.tempMemCache setObject:value forKey:key];
    }
    return value;
}
- (id)read:(NSArray *)keys perform:(id(^)(void))perform {
    id value = [self read:keys];
    if (value) {
        return value;
    }
    value = perform();
    if (value) {
        NSError *writeError = nil;
        if (![self write:value keys:keys error:&writeError]) {
            NSLog(@"write error: %@",writeError);
        }
    }
    return value;
}

- (BOOL)write:(id)value keys:(NSArray *)keys {
    return [self write:value keys:keys error:NULL];
}
- (BOOL)write:(id)value keys:(NSArray *)keys error:(NSError **)error {
    NSString *key = [self keyPathForKeys:keys];
    BOOL success = [self performWrite:value forKey:key error:error];
    if (success) {
        [self.tempMemCache setObject:value forKey:key];
    }
    return success;
}

- (BOOL)deleteWithKeys:(NSArray *)keys {
    return [self deleteWithKeys:keys error:NULL];
}
- (BOOL)deleteWithKeys:(NSArray *)keys error:(NSError **)error {
    NSString *key = [self keyPathForKeys:keys];
    [self.tempMemCache removeObjectForKey:key];
    return [self performDeleteWithKey:key error:error];
}

- (NSString *)keyPathForKeys:(NSArray *)keys {
    return [keys componentsJoinedByString:@"_"];
}


- (id)performReadForKey:(NSString *)key {
    [NSException raise:OSDCacheException format:@"Override %s in subclass",__PRETTY_FUNCTION__];
    return nil;
}
- (BOOL)performWrite:(id)write forKey:(NSString *)key error:(NSError **)error {
    [NSException raise:OSDCacheException format:@"Override %s in subclass",__PRETTY_FUNCTION__];
    return NO;
}
- (BOOL)performDeleteWithKey:(NSString *)key error:(NSError **)error {
    [NSException raise:OSDCacheException format:@"Override %s in subclass",__PRETTY_FUNCTION__];
    return NO;
}
- (void)performCacheClear {
    [NSException raise:OSDCacheException format:@"Needs to be overriden"];
}

#pragma mark -
#pragma mark - Metadata
- (NSUInteger)objectsInCache {
    return 0;
}

@end

@implementation OSDDiskCache

- (void)performCacheClear {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachePath]]) {
        NSError *clearError = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:[self cachePath] error:&clearError]) {
            NSLog(@"Clear cache error: %@",clearError);
        }
    }
}

- (id)performReadForKey:(NSString *)key {
    NSString *path = [[[self cachePath] stringByAppendingPathComponent:key] stringByAppendingPathExtension:@"dat"];
    return [NSData dataWithContentsOfFile:path];
}
- (BOOL)performWrite:(id)write forKey:(NSString *)key error:(NSError **)error {
    NSString *path = [[[self cachePath] stringByAppendingPathComponent:key] stringByAppendingPathExtension:@"dat"];
    return [write writeToFile:path options:NSDataWritingAtomic error:error];
}

@end

@implementation OSDMemCache

- (id)performReadForKey:(NSString *)key {
    return nil;
}
- (BOOL)performWrite:(id)write forKey:(NSString *)key error:(NSError **)error {
    return YES;
}
- (void)performCacheClear {
    
}

@end

@implementation OSDTmpCache

- (NSString *)cachePath {
    static NSString *cachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *base = [self baseCachePath];
        if (!base) {
            cachePath = nil;
        } else {
            cachePath = [base stringByAppendingPathComponent:@"OSDTmpCache"];
        }
    });
    return cachePath;
}

- (void)dealloc {
    [self clear];
}

@end

NSString * const OSDCacheException = @"OSDCacheException";
NSString * const OSDCacheErrorDomain = @"OSDCacheErrorDomain";
float_t const OSDCacheVersionNumber = OSDCacheVersion_1_0;
