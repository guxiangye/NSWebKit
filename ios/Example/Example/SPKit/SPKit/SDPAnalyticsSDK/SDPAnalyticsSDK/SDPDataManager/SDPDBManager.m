//
//  SDPDBManager.m
//  gather
//
//  Created by jhon on 2020/5/22.
//  Copyright © 2020 shengpay. All rights reserved.
//

#import "SDPDBManager.h"
#import "SDPReportManager.h"
#import "SDPEncryptManager.h"
#import "SDPFMDatabaseAdditions.h"
#import "SDPFMDatabaseQueue.h"

/** 数据库存放路径 */
#define DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface SDPDBManager ()

//数据库队列
@property (nonatomic, strong) SDPFMDatabaseQueue *queue;
//采集数据线程操作队列
@property (nonatomic, strong) NSOperationQueue *opQueue;

@end


@implementation SDPDBManager

#pragma mark - 创建单例
+(instancetype)shareDataManager
{
    static dispatch_once_t onceToken;
    static SDPDBManager *dataManager;
    dispatch_once(&onceToken, ^{
        dataManager = [SDPDBManager new];
    });
    return dataManager;
}

#pragma mark - 创建数据库队列
- (SDPFMDatabaseQueue *)queue {
    if (_queue == nil) {
        _queue = [SDPFMDatabaseQueue databaseQueueWithPath:[DOCUMENT_PATH stringByAppendingPathComponent:@"sdp.db"]];
    }
    return _queue;
}

#pragma mark - 创建任务操作队列
- (NSOperationQueue *)opQueue {
    if (_opQueue == nil) {
        _opQueue = [[NSOperationQueue alloc] init];
        _opQueue.maxConcurrentOperationCount = 3;
    }
    return _opQueue;
}

#pragma mark - 添加信息
-(void)addGatherInfo:(nullable NSDictionary *)info withPriority:(NSUInteger)priority{
    [self.opQueue addOperationWithBlock:^{
        NSString *tableName = [NSString stringWithFormat:@"t_%ld",priority];
        if (![self isExistTable:tableName]) {
            [self creatTable:tableName];
        }
        __block BOOL success;
        [self.queue inDatabase:^(SDPFMDatabase * _Nonnull db) {
            NSString *insertSql = [NSString stringWithFormat:@"insert into %@(data) values (?)",tableName];
            BOOL result = [db executeUpdate:insertSql, [SDPEncryptManager sdpEncryptAES:[self dicToJsonString:info] withKey:@"cNitHORrbkeYVE03"]];//aes加密存储
            if (result) {
                success = YES;
                NSLog(@"添加成功");
            } else {
                success = NO;
                NSLog(@"添加失败");
            }
        }];
        //上报数据
        if (success) {
            [[SDPReportManager sharedInstance] dispatch:priority];
        }
    }];
}

#pragma mark - 删除信息
-(void)deleteGatherInfoWithPriority:(NSUInteger)priority withNum:(NSInteger)num{
    NSString *tableName = [NSString stringWithFormat:@"t_%ld",priority];
    [self.queue inDatabase:^(SDPFMDatabase * _Nonnull db) {
        NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where identifier in (select identifier from %@ order by identifier ASC limit %ld)",tableName,tableName,num];
        BOOL result = [db executeUpdate:deleteSql];
        if (result) {
            NSLog(@"删除成功");
        } else {
            NSLog(@"删除失败");
        }
    }];
}

#pragma mark - 查询数据条数
- (NSUInteger)queryGatherInfoNumWithPriority:(NSUInteger)priority
{
    NSString *tableName = [NSString stringWithFormat:@"t_%ld",priority];
    __block int count = 0;
    [self.queue inDatabase:^(SDPFMDatabase * _Nonnull db) {
        count = [db intForQuery:[NSString stringWithFormat:@"select count(*) from %@",tableName]];
    }];
    return count;
}

#pragma mark - 获取数据
- (NSMutableArray *)getGatherInfoWithPriority:(NSUInteger)priority withNum:(NSInteger)num{
    NSString *tableName = [NSString stringWithFormat:@"t_%ld",priority];
    NSMutableArray *results = @[].mutableCopy;
    [self.queue inDatabase:^(SDPFMDatabase * _Nonnull db) {
        NSString *querySql = [NSString stringWithFormat:@"select data from %@ order by identifier ASC limit %ld",tableName,num];
        SDPFMResultSet *resultSet = [db executeQuery:querySql];
        // 循环逐行读取数据resultSet next
        while ([resultSet next])
        {
            NSString *data = [resultSet stringForColumn:@"data"];
            NSString *str = [SDPEncryptManager sdpDecryptAES:data withKey:@"cNitHORrbkeYVE03"];//aes解密
            [results addObject:[self jsonStringToDic:str]];
        }
    }];
    return results;
}

#pragma mark - 判断表是否存在
-(BOOL)isExistTable:(NSString *)name{
    __block BOOL exist;
    [self.queue inDatabase:^(SDPFMDatabase * _Nonnull db) {
        SDPFMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", name];
        while ([rs next]){
            NSInteger count = [rs intForColumn:@"count"];
            if (0 == count){
                exist = NO;
            }else{
                exist = YES;
            }
        }
    }];
    return exist;
}

#pragma mark - 创建表
- (void)creatTable:(NSString *)name {
    [self.queue inDatabase:^(SDPFMDatabase * _Nonnull db) {
        NSString *createSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (identifier integer PRIMARY KEY AUTOINCREMENT, data text NOT NULL)", name];;
        BOOL result = [db executeUpdate:createSql];
        if (result) {
            NSLog(@"建表成功");
        } else {
            NSLog(@"建表失败 %d", result);
        }
    }];
}


#pragma mark - 字典转json
-(NSString *)dicToJsonString:(NSDictionary *)dic
{
    NSDictionary *tempDic = @{@"msgContent" : dic};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}
#pragma mark - 字典转json
- (NSDictionary *)jsonStringToDic:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        return nil;
    }
    return dic;
}

@end
