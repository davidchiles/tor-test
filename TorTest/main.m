//
//  main.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "TRTURLProtocol.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        [NSURLProtocol registerClass:[TRTURLProtocol class]];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
