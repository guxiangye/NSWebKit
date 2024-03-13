//
//  NSStorage.m
// NSKit
//
//  Created by Neil on 2022/3/10.
//

#import "NSStorage.h"

#define kStorageDefaultGroupName @"StorageDefaultGroup"

#define kStorageExpireTime       @"expireTime"
#define kStorageValue            @"value"

@implementation NSStorage
#pragma mark - 获取存储文件路径

+ (NSString *)getStorageFilePath:(NSString *)groupName {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *storageFolder = [docDir stringByAppendingPathComponent:NSStringFromClass(NSStorage.class)];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    BOOL isDir = YES;

    if (![fileManage fileExistsAtPath:storageFolder isDirectory:&isDir]) {
        [fileManage createDirectoryAtPath:storageFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return [storageFolder stringByAppendingPathComponent:groupName];
}

#pragma mark - 存值

+ (void)set:(NSString *)key value:(id<NSCopying>)value {
    [self set:key value:value groupName:nil];
}

+ (void)set:(NSString *)key value:(id<NSCopying>)value groupName:(nullable NSString *)groupName {
    [self set:key value:value groupName:groupName validSecond:0];
}

+ (void)set:(NSString *)key value:(id<NSCopying>)value groupName:(NSString *)groupName validSecond:(NSUInteger)validSecond {
    if (value == nil) {
        return;
    }
    if (groupName.length == 0) {
        groupName = kStorageDefaultGroupName;
    }

    NSInteger expireTime = [[NSDate date]timeIntervalSince1970] + validSecond;

    if (validSecond == 0) {
        expireTime = NSIntegerMax;
    }

    NSDictionary *storageValue = @{
            kStorageValue: value, kStorageExpireTime: @(expireTime)
    };

    NSString *filePath = [self getStorageFilePath:groupName];

    NSMutableDictionary *groupInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    if (groupInfo == nil) {
        groupInfo = @{}.mutableCopy;
    }

    [groupInfo setObject:storageValue forKey:key];

    [NSKeyedArchiver archiveRootObject:groupInfo toFile:filePath];
}

#pragma mark - 取值

+ (id)get:(NSString *)key {
    return [self get:key groupName:nil];
}

+ (id)get:(NSString *)key groupName:(nullable NSString *)groupName {
    if (groupName.length == 0) {
        groupName = kStorageDefaultGroupName;
    }

    NSString *filePath = [self getStorageFilePath:groupName];

    NSMutableDictionary *groupInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    NSDictionary *storageValue = [groupInfo objectForKey:key];

    if (storageValue && [[storageValue objectForKey:kStorageExpireTime]integerValue] > [[NSDate date]timeIntervalSince1970]) {
        return [storageValue objectForKey:kStorageValue];
    }

    return nil;
}

#pragma mark - 清除
+ (void)remove:(NSString *)key {
    [self remove:key groupName:nil];
}

+ (void)remove:(NSString *)key groupName:(nullable NSString *)groupName {
    if (groupName.length == 0) {
        groupName = kStorageDefaultGroupName;
    }

    NSString *filePath = [self getStorageFilePath:groupName];
    NSMutableDictionary *groupInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    [groupInfo removeObjectForKey:key];
    [NSKeyedArchiver archiveRootObject:groupInfo toFile:filePath];
}

+ (void)clear {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *storageFolder = [docDir stringByAppendingPathComponent:NSStringFromClass(NSStorage.class)];
    NSFileManager *fileManage = [NSFileManager defaultManager];

    [fileManage removeItemAtPath:storageFolder error:nil];
}

+ (void)clearWithGroupName:(nullable NSString *)groupName {
    if (groupName.length == 0) {
        groupName = kStorageDefaultGroupName;
    }

    NSString *filePath = [self getStorageFilePath:groupName];
    NSFileManager *fileManage = [NSFileManager defaultManager];

    [fileManage removeItemAtPath:filePath error:nil];
}

@end
