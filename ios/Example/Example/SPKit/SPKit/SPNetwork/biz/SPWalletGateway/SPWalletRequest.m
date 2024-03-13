//
//  SPMerchantRequest.m
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import "SPWalletRequest.h"
#import "SPWalletNetCallImp.h"
@implementation SPWalletRequest

-(SPNetCall *)buildNetCall{
    return [[SPWalletNetCallImp alloc]initWithRequest:self];
}
@end
