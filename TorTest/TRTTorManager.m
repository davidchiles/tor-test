//
//  TorManager.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTTorManager.h"
#import "OnionKit.h"

@interface TRTTorManager ()

@property (nonatomic, copy) void (^torCompletionBlock)(NSError *error);
@property (nonatomic, strong) id<NSObject> didStartObserver;
@property (nonatomic, strong) id<NSObject> didStopObserver;

@end

@implementation TRTTorManager

- (void)startTorWithCompletion:(void (^)(NSError *))completion
{
    if(![self isTorRunning])
    {
        self.torCompletionBlock = completion;
        
        [[OnionKit sharedInstance] addObserver:self forKeyPath:NSStringFromSelector(@selector(isRunning)) options:NSKeyValueObservingOptionNew context:NULL];
        [[OnionKit sharedInstance] start];
    }
    else if (completion){
        completion(nil);
    }
    
}

- (BOOL)isTorRunning
{
    return [OnionKit sharedInstance].isRunning;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(isRunning))] && [object isEqual:[OnionKit sharedInstance]]) {
        BOOL isRunning = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if(self.torCompletionBlock)
        {
            NSError *error = nil;
            if (!isRunning) {
                error = [NSError errorWithDomain:@"TRTErrorDomain" code:101 userInfo:nil];
            }
            self.torCompletionBlock(error);
        }
    }
}

+ (instancetype)sharedInstance
{
    static TRTTorManager *_defaultManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _defaultManager = [[self alloc] init];
    });
    return _defaultManager;
}

@end
