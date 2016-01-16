//
//  IQURLConnection.m
// https://github.com/hackiftekhar/IQURLConnection
// Copyright (c) 2013-14 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "IQURLConnection.h"

@interface IQURLConnection ()
{
    NSMutableData *_data;
}

@end

@implementation IQURLConnection

@synthesize response = _response;

static NSOperationQueue *queue;

+(void)initialize
{
    [super initialize];
    
    queue = [[NSOperationQueue alloc] init];
}

+ (IQURLConnection*)sendAsynchronousRequest:(NSMutableURLRequest *)request
                              responseBlock:(IQURLConnectionResponseBlock)responseBlock
                        uploadProgressBlock:(IQURLConnectionProgressBlock)uploadProgress
                      downloadProgressBlock:(IQURLConnectionProgressBlock)downloadProgress
                          completionHandler:(IQURLConnectionDataCompletionBlock)completion
{
    IQURLConnection *asyncRequest = [[IQURLConnection alloc] initWithRequest:request
                                                                  resumeData:nil
                                                               responseBlock:responseBlock
                                                         uploadProgressBlock:uploadProgress
                                                       downloadProgressBlock:downloadProgress
                                                             completionBlock:completion];
    [asyncRequest start];
    
    return asyncRequest;
}

- (instancetype)initWithRequest:(NSMutableURLRequest *)request
                     resumeData:(NSData*)dataToResume
                  responseBlock:(IQURLConnectionResponseBlock)responseBlock
            uploadProgressBlock:(IQURLConnectionProgressBlock)uploadProgress
          downloadProgressBlock:(IQURLConnectionProgressBlock)downloadProgress
                completionBlock:(IQURLConnectionDataCompletionBlock)completion
{
    if ([dataToResume length])
    {
        [request addValue:[NSString stringWithFormat: @"bytes=%lu-",(unsigned long)[dataToResume length]] forHTTPHeaderField:@"Range"];
    }
    
    if (self = [super initWithRequest:request delegate:self startImmediately:NO])
    {
        [self setDelegateQueue:queue];
        _uploadProgressBlock = uploadProgress;
        _downloadProgressBlock = downloadProgress;
        _dataCompletionBlock = completion;
        _responseBlock = responseBlock;
        
        _data = [[NSMutableData alloc] initWithData:dataToResume];
        _expectedContentLength = NSURLResponseUnknownLength;
    }
    return self;
}

-(NSCachedURLResponse *)cachedURLResponse
{
    return [[NSURLCache sharedURLCache] cachedResponseForRequest:self.originalRequest];
}

-(NSDictionary *)cachedDictionaryResponse
{
    NSData *data = [[self cachedURLResponse] data];
    
    if (data)
    {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    else
    {
        return nil;
    }
}

-(NSData *)responseData
{
    return _data;
}

-(void)sendDownloadProgress:(CGFloat)progress
{
    if (_downloadProgressBlock && _expectedContentLength!=NSURLResponseUnknownLength)
    {
        if ([NSThread isMainThread])
        {
            _downloadProgressBlock(progress);
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_downloadProgressBlock) _downloadProgressBlock(progress);
            });
        }
    }
}

-(void)sendUploadProgress:(CGFloat)progress
{
    if (_uploadProgressBlock)
    {
        if ([NSThread isMainThread])
        {
            _uploadProgressBlock(progress);
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_uploadProgressBlock)   _uploadProgressBlock(progress);
            });
        }
    }
}

-(void)sendCompletionData:(NSData*)data error:(NSError*)error
{
    if (_dataCompletionBlock)
    {
        if ([NSThread isMainThread])
        {
            _dataCompletionBlock(data,error);
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_dataCompletionBlock)   _dataCompletionBlock(data,error);
            });
        }
    }
}

-(void)sendResponse:(NSHTTPURLResponse*)response
{
    if (_responseBlock)
    {
        if ([NSThread isMainThread])
        {
            _responseBlock(response);
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_responseBlock)
                {
                    _responseBlock(response);
                }
            });
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    _response = response;
    
    NSDictionary *headers = [response allHeaderFields];
    if (headers)
    {
        if (headers[@"Content-Range"])
        {
            NSString *contentRange = headers[@"Content-Range"];
            NSRange range = [contentRange rangeOfString: @"/"];
            NSString *totalBytesCount = [contentRange substringFromIndex: range.location + 1];
            _expectedContentLength = [totalBytesCount floatValue];
        }
        else if (headers[@"Content-Length"])
        {
            _data = [[NSMutableData alloc] init];
            _expectedContentLength = [headers[@"Content-Length"] floatValue];
        }
        else
        {
            _data = [[NSMutableData alloc] init];
            _expectedContentLength = NSURLResponseUnknownLength;
        }
    }
    
    if (_expectedContentLength == 0)
    {
        _expectedContentLength = NSURLResponseUnknownLength;
    }
    
    [self sendResponse:_response];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];

    _totalBytesReceived = [_data length];

    [self sendDownloadProgress:((CGFloat)_totalBytesReceived/_expectedContentLength)];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _error = error;
    
    [self sendCompletionData:_data error:error];
}

-(void)start
{
    [super start];
}

-(void)cancel
{
    [super cancel];
    
    _error = [NSError errorWithDomain:NSStringFromClass([self class]) code:NSURLErrorCancelled userInfo:nil];
    
    [self sendCompletionData:_data error:_error];
    
    _responseBlock = NULL;
    _uploadProgressBlock = NULL;
    _downloadProgressBlock = NULL;
    _dataCompletionBlock = NULL;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self sendCompletionData:_data error:nil];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    _totalBytesWritten = totalBytesWritten;
    _totalBytesExpectedToWrite = totalBytesExpectedToWrite;

    [self sendUploadProgress:((CGFloat)totalBytesWritten/(CGFloat)totalBytesExpectedToWrite)];
}

//https://developer.apple.com/library/ios/technotes/tn2232/_index.html
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    
    id<NSURLAuthenticationChallengeSender> sender = [challenge sender];
    
    if ([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        [sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else
    {
        [sender performDefaultHandlingForAuthenticationChallenge:challenge];
    }
}

@end
