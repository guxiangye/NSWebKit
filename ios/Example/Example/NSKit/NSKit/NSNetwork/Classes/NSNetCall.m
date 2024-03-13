//
//  NSNetCall.m
//  NSKit
//
//  Created by Neil on 2023/5/6.
//

#import "NSObject+YYModel.h"
#import "NSNetworkSessionManager.h"
#import "NSHttpManager.h"
#import "NSNetCall.h"
#import "NSSingleHttpToolBox.h"

@interface NSNetCall ()
@property (nonatomic, assign) BOOL isCanceled;
@end
@implementation NSNetCall
- (instancetype)initWithRequest:(id<NSINetRequest>)request {
    if (self = [super init]) {
        self.request = request;
    }

    return self;
}

- (void)sendAsync:(void (^)(NSNetResponse<id> *response))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSSingleHttpToolBox *toolBox = [[NSHttpManager sharedInstance]getHttpToolBox:[self.request getBaseURL]];

        NSDictionary *param = [(NSObject *)self.request modelToJSONObject];


        NSNetworkRequestOptions *options = [NSNetworkRequestOptions new];

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

                               NSNetResponse *response = [self converDataToModel:responseObjcect
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
                               NSNetResponse *response = [NSNetResponse new];
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

- (NSNetResponse *)converDataToModel:(id)responseData cls:(Class)_class {
    NSNetResponse *response = [NSNetResponse new];

    response.responseData = responseData;
    return response;
}

- (void)cancel {
    self.isCanceled = YES;
}

@end
