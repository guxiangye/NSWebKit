//
//  NSData+Conversion.h
//  MPOS
//
//  Created by jinke on 11/22/12.
//  Copyright (c) 2012 Shengpay Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSData_Conversion)

#pragma mark - String Conversion
- (NSString *)hexadecimalString;
- (NSString*)convertToHexStr;
@end
