//
//  IQNetworkTask.m
// https://github.com/hackiftekhar/IQNetworkTaskManager
// Copyright (c) 2016 Iftekhar Qurashi.
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

#import "IQNetworkTask.h"
#import "IQURLConnection.h"

NSString *const IQNetworkTaskDidFinishNotification      =   @"IQNetworkTaskDidFinishNotification";

@implementation IQNetworkTask

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self) {
        _request = request;
        _statusChangeTargets = [[NSMutableSet alloc] init];
        _downloadProgressTargets = [[NSMutableSet alloc] init];
        _uploadProgressTargets = [[NSMutableSet alloc] init];
        _completionTargets = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)start
{
    _status = IQNetworkTaskStatusPreparing;
    
    for (NSInvocation *invocation in _statusChangeTargets)
    {
        [invocation setArgument:&_status atIndex:2];
        [invocation invoke];
    }

    _connection = [[IQURLConnection alloc] initWithRequest:[_request mutableCopy] resumeData:_dataToResume responseBlock:^(NSHTTPURLResponse *response) {
        
        IQNetworkTaskStatus _previousStatus = _status;
        _status = IQNetworkTaskStatusDownloading;
        
        if (_previousStatus != _status)
        {
            for (NSInvocation *invocation in _statusChangeTargets)
            {
                [invocation setArgument:&_status atIndex:2];
                [invocation invoke];
            }
        }

    } uploadProgressBlock:^(CGFloat progress) {

        _uploadProgress = progress;
        
        IQNetworkTaskStatus _previousStatus = _status;
        _status = IQNetworkTaskStatusUploading;
        
        for (NSInvocation *invocation in _uploadProgressTargets)
        {
            [invocation setArgument:&_uploadProgress atIndex:2];
            [invocation invoke];
        }

        if (_uploadProgress == 1.0)
        {
            _status = IQNetworkTaskStatusWaiting;
            
            if (_previousStatus != _status)
            {
                for (NSInvocation *invocation in _statusChangeTargets)
                {
                    [invocation setArgument:&_status atIndex:2];
                    [invocation invoke];
                }
            }
        }
        else
        {
            if (_previousStatus != _status)
            {
                for (NSInvocation *invocation in _statusChangeTargets)
                {
                    [invocation setArgument:&_status atIndex:2];
                    [invocation invoke];
                }
            }
        }
        
    } downloadProgressBlock:^(CGFloat progress) {
        _downloadProgress = progress;
        
        IQNetworkTaskStatus _previousStatus = _status;
        _status = IQNetworkTaskStatusDownloading;
        
        for (NSInvocation *invocation in _downloadProgressTargets)
        {
            [invocation setArgument:&_downloadProgress atIndex:2];
            [invocation invoke];
        }

        if (_previousStatus != _status)
        {
            for (NSInvocation *invocation in _statusChangeTargets)
            {
                [invocation setArgument:&_status atIndex:2];
                [invocation invoke];
            }
        }

    } completionBlock:^(NSData *result, NSError *error) {
        
        IQNetworkTaskStatus _previousStatus = _status;

        if ([error code] == 100)
        {
            _status = IQNetworkTaskStatusPaused;
            _dataToResume = result;
        }
        else
        {
            [self handleResponseData:&result error:&error];

            if (result)
            {
                _status = IQNetworkTaskStatusDownloaded;
            }
            else
            {
                _status = IQNetworkTaskStatusFailed;
            }

            _connection = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:IQNetworkTaskDidFinishNotification object:self];
        }
        
        for (NSInvocation *invocation in _completionTargets)
        {
            [invocation setArgument:&result atIndex:2];
            [invocation setArgument:&error atIndex:3];
            [invocation invoke];
        }

        if (_previousStatus != _status)
        {
            for (NSInvocation *invocation in _statusChangeTargets)
            {
                [invocation setArgument:&_status atIndex:2];
                [invocation invoke];
            }
        }
    }];
    
    [_connection start];
}

-(void)pause
{
    [_connection cancel];
}

-(void)resume
{
    [self start];
    
    for (NSInvocation *invocation in _uploadProgressTargets)
    {
        [invocation setArgument:&_uploadProgress atIndex:2];
        [invocation invoke];
    }
    
    for (NSInvocation *invocation in _downloadProgressTargets)
    {
        [invocation setArgument:&_downloadProgress atIndex:2];
        [invocation invoke];
    }
}

-(void)cancel
{
    [_connection cancel];
    _connection = nil;
    _dataToResume = nil;
    [_statusChangeTargets removeAllObjects];
    [_downloadProgressTargets removeAllObjects];
    [_uploadProgressTargets removeAllObjects];
    [_completionTargets removeAllObjects];
}

- (void)addStatusUpdateTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    invocation.target = target;
    invocation.selector = action;
    
    [_statusChangeTargets addObject:invocation];
}

- (void)removeStatusUpdateTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = nil;
    
    for (NSInvocation *progressInvocation in _statusChangeTargets)
    {
        if ([progressInvocation.target isEqual:target] && progressInvocation.selector == action)
        {
            invocation = progressInvocation;
            break;
        }
    }
    
    if (invocation)
    {
        [_statusChangeTargets removeObject:invocation];
    }
}

- (void)addDownloadProgressTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    invocation.target = target;
    invocation.selector = action;
    
    [_downloadProgressTargets addObject:invocation];
}

- (void)removeDownloadProgressTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = nil;
    
    for (NSInvocation *progressInvocation in _downloadProgressTargets)
    {
        if ([progressInvocation.target isEqual:target] && progressInvocation.selector == action)
        {
            invocation = progressInvocation;
            break;
        }
    }
    
    if (invocation)
    {
        [_downloadProgressTargets removeObject:invocation];
    }
}

- (void)addUploadProgressTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    invocation.target = target;
    invocation.selector = action;
    
    [_uploadProgressTargets addObject:invocation];
}

- (void)removeUploadProgressTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = nil;
    
    for (NSInvocation *progressInvocation in _uploadProgressTargets)
    {
        if ([progressInvocation.target isEqual:target] && progressInvocation.selector == action)
        {
            invocation = progressInvocation;
            break;
        }
    }
    
    if (invocation)
    {
        [_uploadProgressTargets removeObject:invocation];
    }
}

- (void)addCompletionTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
    invocation.target = target;
    invocation.selector = action;
    [_completionTargets addObject:invocation];
}

- (void)removeCompletionTarget:(id)target action:(SEL)action
{
    NSInvocation *invocation = nil;
    
    for (NSInvocation *completionInvocation in _completionTargets)
    {
        if ([completionInvocation.target isEqual:target] && completionInvocation.selector == action)
        {
            invocation = completionInvocation;
            break;
        }
    }
    
    if (invocation)
    {
        [_completionTargets removeObject:invocation];
    }
}

-(void)handleResponseData:(NSData * _Nullable * _Nullable)data error:(NSError * _Nullable * _Nullable)error
{
}

@end
