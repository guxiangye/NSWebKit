//
//  UIGestureRecognizer+NSAutoTrack.m
//  NSAutoTrack
//
//  Created by Neil on 2020/5/19.
//  Copyright © 2020 Neil. All rights reserved.
//

#import "UIGestureRecognizer+NSAutoTrack.h"
#import <objc/runtime.h>
static const int sdp_gesture_block_key;

@interface NSGestureRecognizerBlockTarge : NSObject
@property (nonatomic, copy) void (^ block)(id sender);
- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;
@end

@implementation NSGestureRecognizerBlockTarge
- (id)initWithBlock:(void (^)(id sender))block {
    if (self = [super init]) {
        self.block = block;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (self.block) {
        self.block(sender);
    }
}

@end

@implementation UIGestureRecognizer (NSAutoTrack)

- (void)addActionBlock:(void (^)(UIGestureRecognizer *sender))block {
    NSGestureRecognizerBlockTarge *target = [[NSGestureRecognizerBlockTarge alloc] initWithBlock:block];
    [self addTarget:target action:@selector(invoke:)];
    NSMutableArray *targets = [self _sdp_allGestureRecognizerBlockTargets];
    [targets addObject:target];
}

- (NSMutableArray *)_sdp_allGestureRecognizerBlockTargets {
    NSMutableArray *targets = objc_getAssociatedObject(self, &sdp_gesture_block_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &sdp_gesture_block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
