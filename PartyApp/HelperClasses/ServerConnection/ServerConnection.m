//
//  ServerConnection.m
//  TextFieldDemo
//
//  Created by Varun on 4/05/2014.
//  Copyright (c) 2014 Channi. All rights reserved.
//

#import "ServerConnection.h"

@implementation ServerConnection

- (void)fetchDataWithRequest:(NSMutableURLRequest *)request
                   forTarget:(id)target
                 andSelector:(SEL)selector {
    
    _controller = target;
    _handler = selector;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

#pragma mark - Delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [_controller performSelectorOnMainThread:_handler
                              withObject:_responseData
                           waitUntilDone:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    
    [_controller performSelectorOnMainThread:_handler
                              withObject:nil
                           waitUntilDone:YES];
}

@end