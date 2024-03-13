//
//  SPNetCall.m
//  SPKit
//
//  Created by 高鹏程 on 2023/5/6.
//

#import "NSObject+YYModel.h"
#import "SDPNetworkSessionManager.h"
#import "SPHttpManager.h"
#import "SPNetCall.h"
#import "SPSingleHttpToolBox.h"

@interface SPNetCall ()
@property (nonatomic, assign) BOOL isCanceled;
@end
@implementation SPNetCall
- (instancetype)initWithRequest:(id<SPINetRequest>)request {
    if (self = [super init]) {
        self.request = request;
    }

    return self;
}

- (void)sendAsync:(void (^)(SPNetResponse<id> *response))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SPSingleHttpToolBox *toolBox = [[SPHttpManager sharedInstance]getHttpToolBox:[self.request getBaseURL]];

        NSDictionary *param = [(NSObject *)self.request modelToJSONObject];


        SDPNetworkRequestOptions *options = [SDPNetworkRequestOptions new];

        options.baseURL = self.request.getBaseURL;
        options.method = self.request.getHttpMethod;
        options.path = self.request.getOperation;
        options.parameters = param.mutableCopy;
        options.retryCount = self.retryCount;

        options.header[@"Content-Type"] = self.request.getContentType;


        [toolBox.session dataTaskWithNetworkRequestOptions:options
                                                   success:^(NSURLSessionDataTask *_Nonnull task, id _Nonnull responseObjcect) {
            if (self.isCanceled) {
                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                               Class class = nil;

                               if ([self.request respondsToSelector:@selector(getResponseClass)]) {
                                   class = [self.request getResponseClass];
                               }

                               SPNetResponse *response = [self converDataToModel:responseObjcect
                                                                             cls:class];

                               if (callback) {
                                   callback(response);
                               }
                           });
        }
                                                   failure:^(NSURLSessionDataTask *_Nonnull task, NSError *_Nonnull error) {
            if (self.isCanceled) {
                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                               SPNetResponse *response = [SPNetResponse new];
                               response.isSuccessful = NO;
                               response.code = [NSString stringWithFormat:@"%ld", (long)error.code];
                               response.message = error.description;

                               if (callback) {
                                   callback(response);
                               }
                           });
        }];
    });
}

- (SPNetResponse *)converDataToModel:(id)responseData cls:(Class)_class {
    SPNetResponse *response = [SPNetResponse new];

    response.responseData = responseData;
    return response;
}

- (void)cancel {
    self.isCanceled = YES;
}

@end
