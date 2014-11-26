//
//  TRTURLProtocol.m
//  TorTest
//
//  Created by David Chiles on 11/26/14.
//  Copyright (c) 2014 David Chiles. All rights reserved.
//

#import "TRTURLProtocol.h"
#import "CKHTTPConnection.h"
#import "TRTTorManager.h"

@interface TRTURLProtocol () <CKHTTPConnectionDelegate>

@property (nonatomic, strong) NSURLRequest *URLRequest;
@property (nonatomic, strong) CKHTTPConnection *connection;
@property (nonatomic, strong) NSMutableData *data;

@end

@implementation TRTURLProtocol

#pragma - mark NSURLProtocol Methods

- (instancetype)initWithTask:(NSURLSessionTask *)task cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    return [super initWithTask:task cachedResponse:cachedResponse client:client];
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    if (self = [super initWithRequest:request cachedResponse:cachedResponse client:client]) {
        self.URLRequest = request;
    }
    return self;
}

- (void)startLoading
{
    self.connection = [CKHTTPConnection connectionWithRequest:[self request] settings:@{@"kCKTorSocksPort" : @([TRTTorManager sharedInstance].port)} delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ( !([[[[request URL] scheme] lowercaseString] isEqualToString:@"file"] ||
           [[[[request URL] scheme] lowercaseString] isEqualToString:@"data"]
           )
        ) {
        // Previously we checked if it matched "http" or "https". Apparently
        // UIWebView can attempt to make FTP connections for HTML page resources (i.e.
        // a <link> tag for a CSS file with an FTP scheme.). So we whitelist
        // file:// and data:// urls and attempt to tunnel everything else over Tor.
        return YES;
    } else {
        return NO;
    }
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

#pragma - mark CKHTTPConnectionDelegate Methods

- (void)HTTPConnection:(CKHTTPConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)HTTPConnection:(CKHTTPConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (void)HTTPConnection:(CKHTTPConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    self.data = nil;
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
}

- (void)HTTPConnection:(CKHTTPConnection *)connection didReceiveData:(NSData *)data
{
    if(!self.data) {
        self.data = [NSMutableData data];
    }
    
    [self.data appendData:data];
    
    [self.client URLProtocol:self didLoadData:data];
}

- (void)HTTPConnectionDidFinishLoading:(CKHTTPConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
    self.data = nil;
}

- (void)HTTPConnection:(CKHTTPConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    self.data = nil;
}


@end
