//
//  NSImageURLProtocol.m
//  Pods
//
//  Created by Neil on 2023/3/21.
//

#import "NSImageURLProtocol.h"
#import "NSURLProtocol+WebKitSupport.h"

static NSString* const NSFilteredKey = @"NSFilteredKey";
@implementation NSImageURLProtocol

+(void)registerSelf{
    [NSURLProtocol registerClass:[NSImageURLProtocol class]];
    [NSURLProtocol wk_registerScheme:NSSchemeKey];
}
+(void)unregisterSelf{
    [NSURLProtocol unregisterClass:[NSImageURLProtocol class]];
    [NSURLProtocol wk_unregisterScheme:NSSchemeKey];
}

/** 决定是否处理该请求 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if([request.URL.scheme isEqualToString:NSFilteredKey] && [NSURLProtocol propertyForKey:NSFilteredKey inRequest:request] == nil){
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest* request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:NSFilteredKey inRequest:request];
    NSString *fileName = [request.URL.absoluteString lastPathComponent];
    NSString *tmpDir =  NSTemporaryDirectory();
    NSString *filePath = [tmpDir stringByAppendingPathComponent:fileName];
    
    UIImage *image = [[UIImage alloc]initWithContentsOfFile:filePath];
    NSData* data = UIImagePNGRepresentation(image);
    NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:nil];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

@end
