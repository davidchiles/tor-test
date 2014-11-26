//
//  TorManager.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTTorManager.h"
#import "CPAProxy.h"

@interface TRTTorManager ()

@property (nonatomic, strong) NSString *hostname;
@property (nonatomic) NSUInteger port;

@property (nonatomic, strong) CPAProxyManager *torManager;

@end

@implementation TRTTorManager

- (instancetype)init {
    if (self = [super init]) {
        
        NSURL *cpaProxyBundleURL = [[NSBundle mainBundle] URLForResource:@"CPAProxy" withExtension:@"bundle"];
        NSBundle *cpaProxyBundle = [NSBundle bundleWithURL:cpaProxyBundleURL];
        NSString *torrcPath = [cpaProxyBundle pathForResource:@"torrc" ofType:nil];
        NSString *geoipPath = [cpaProxyBundle pathForResource:@"geoip" ofType:nil];
        
        
        NSString *torDataDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tor"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:torDataDirectoryPath]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:torDataDirectoryPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        CPAConfiguration *configuration = [CPAConfiguration configurationWithTorrcPath:torrcPath geoipPath:geoipPath torDataDirectoryPath:torDataDirectoryPath];
        self.torManager = [CPAProxyManager proxyWithConfiguration:configuration];
    }
    return self;
}

- (void)startTorWithCompletion:(void (^)(NSString *,NSUInteger, NSError *))completion
{
    if (self.torManager.status != CPAStatusClosed && completion) {
        completion(self.torManager.SOCKSHost,self.torManager.SOCKSPort,nil);
    }
    else {
        [self.torManager setupWithCompletion:^(NSString *socksHost, NSUInteger socksPort, NSError *error) {
            if (error) {
                self.hostname = nil;
                self.port = 0;
                if (completion) {
                    completion(nil,0,error);
                }
            } else {
                self.hostname = socksHost;
                self.port = socksPort;
                if (completion) {
                    completion(socksHost,socksPort,nil);
                }
            }
        } progress:nil];
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
