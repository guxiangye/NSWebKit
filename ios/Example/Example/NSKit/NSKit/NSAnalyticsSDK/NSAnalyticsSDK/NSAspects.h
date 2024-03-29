//
//  Aspects.h
//  Aspects - A delightful, simple library for aspect oriented programming.
//
//  Copyright (c) 2014 Peter Steinberger. Licensed under the MIT license.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, NSAspectOptions) {
    NSAspectPositionAfter   = 0,            /// Called after the original implementation (default)
    NSAspectPositionInstead = 1,            /// Will replace the original implementation.
    NSAspectPositionBefore  = 2,            /// Called before the original implementation.
    
    NSAspectOptionAutomaticRemoval = 1 << 3 /// Will remove the hook after the first execution.
};

/// Opaque Aspect Token that allows to deregister the hook.
@protocol NSAspectToken <NSObject>

/// Deregisters an aspect.
/// @return YES if deregistration is successful, otherwise NO.
- (BOOL)remove;

@end

/// The NSAspectInfo protocol is the first parameter of our block syntax.
@protocol NSAspectInfo <NSObject>

/// The instance that is currently hooked.
- (id)instance;

/// The original invocation of the hooked method.
- (NSInvocation *)originalInvocation;

/// All method arguments, boxed. This is lazily evaluated.
- (NSArray *)arguments;

@end

/**
 Aspects uses Objective-C message forwarding to hook into messages. This will create some overhead. Don't add aspects to methods that are called a lot. Aspects is meant for view/controller code that is not called a 1000 times per second.

 Adding aspects returns an opaque token which can be used to deregister again. All calls are thread safe.
 */
@interface NSObject (NSAspects)

/// Adds a block of code before/instead/after the current `selector` for a specific class.
///
/// @param block Aspects replicates the type signature of the method being hooked.
/// The first parameter will be `id<NSAspectInfo>`, followed by all parameters of the method.
/// These parameters are optional and will be filled to match the block signature.
/// You can even use an empty block, or one that simple gets `id<NSAspectInfo>`.
///
/// @note Hooking static methods is not supported.
/// @return A token which allows to later deregister the aspect.
+ (id<NSAspectToken>)sdp_aspect_hookSelector:(SEL)selector
                           withOptions:(NSAspectOptions)options
                            usingBlock:(void(^)(id<NSAspectInfo>info))block;

/// Adds a block of code before/instead/after the current `selector` for a specific instance.
- (id<NSAspectToken>)sdp_aspect_hookSelector:(SEL)selector
                           withOptions:(NSAspectOptions)options
                            usingBlock:(void(^)(id<NSAspectInfo>info))block;

@end


typedef NS_ENUM(NSUInteger, NSAspectErrorErrorCode) {
    NSAspectErrorSelectorBlacklisted,                   /// Selectors like release, retain, autorelease are blacklisted.
    NSAspectErrorDoesNotRespondToSelector,              /// Selector could not be found.
    NSAspectErrorSelectorDeallocPosition,               /// When hooking dealloc, only NSAspectPositionBefore is allowed.
    NSAspectErrorSelectorAlreadyHookedInClassHierarchy, /// Statically hooking the same method in subclasses is not allowed.
    NSAspectErrorFailedToAllocateClassPair,             /// The runtime failed creating a class pair.
    NSAspectErrorMissingBlockSignature,                 /// The block misses compile time signature info and can't be called.
    NSAspectErrorIncompatibleBlockSignature,            /// The block signature does not match the method or is too large.

    NSAspectErrorRemoveObjectAlreadyDeallocated = 100   /// (for removing) The object hooked is already deallocated.
};

extern NSString *const NSAspectErrorDomain;
