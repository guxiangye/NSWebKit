//
//  NSMerchantRequest.m
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import "NSWalletRequest.h"
#import "NSWalletNetCallImp.h"
@implementation NSWalletRequest

-(NSNetCall *)buildNetCall{
    return [[NSWalletNetCallImp alloc]initWithRequest:self];
}
@end
