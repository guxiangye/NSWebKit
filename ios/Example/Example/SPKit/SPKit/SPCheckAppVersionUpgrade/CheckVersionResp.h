//
//  CheckVersionResp.h
//  SPKit
//
//  Created by 高鹏程 on 2023/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckVersionResp : NSObject
@property(nonatomic,copy)NSString *authToken;
@property(nonatomic,assign)BOOL forceUpdate;
@property(nonatomic,copy)NSString *releaseInfo;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *versionName;
@property(nonatomic,copy)NSString *versionCode;
@end

NS_ASSUME_NONNULL_END
