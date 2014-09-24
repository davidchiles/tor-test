//
//  TRTTorProxyURLProtocol.m
//  TorTest
//
//  Created by David Chiles on 9/23/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTTorProxyURLProtocol.h"

@interface TRTTorProxyURLProtocol ()

@end

@implementation TRTTorProxyURLProtocol

/*
- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{

}

- (instancetype)initWithTask:(NSURLSessionTask *)task cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    
}
 */

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ( !([[[request URL] scheme] isEqualToString:@"file"] || [[[request URL] scheme] isEqualToString:@"data"])) {
        // Previously we checked if it matched "http" or "https". Apparently
        // UIWebView can attempt to make FTP connections for HTML page resources (i.e.
        // a <link> tag for a CSS file with an FTP scheme.). So we whitelist
        // file:// and data:// urls and attempt to tunnel everything else over Tor.
        return YES;
    } else {
        return NO;
    }
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

@end
