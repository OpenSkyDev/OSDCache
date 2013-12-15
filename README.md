OSDCache
========

A caching class cluster

***

#### Usage

``` Objective-C
NSArray *keys = @[@"cache",@"value"];
NSString *value = [[OSDCache memCache] read:keys perform:^id{
    return @"Cache Value";
}];
NSLog(@"%@",value);
```

`value` will equal `@"Cache Value"`.  If the value isn't in the cache then the `perform` block is called.  The return value is written into the cache, and returned through the call.

The next time this is called, the cached value will be returned instead of the value from the `perform` block.