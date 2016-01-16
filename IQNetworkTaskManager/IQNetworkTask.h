//
//  IQNetworkTask.h
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

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class IQURLConnection;

/**
 `IQNetworkTaskStatusNotStarted`    Not started yet
 `IQNetworkTaskStatusPreparing`     Preparing for data upload
 `IQNetworkTaskStatusUploading`     Uploading http body
 `IQNetworkTaskStatusWaiting`       Waiting for server response
 `IQNetworkTaskStatusDownloading`   Downloading response data
 `IQNetworkTaskStatusPaused`        Paused the network request
 `IQNetworkTaskStatusDownloaded`    Downloaded successfully
 `IQNetworkTaskStatusFailed`        Network request failed
 */
typedef enum IQNetworkTaskStatus
{
    IQNetworkTaskStatusNotStarted = 0,
    IQNetworkTaskStatusPreparing,
    IQNetworkTaskStatusUploading,
    IQNetworkTaskStatusWaiting,
    IQNetworkTaskStatusDownloading,
    IQNetworkTaskStatusPaused,
    IQNetworkTaskStatusDownloaded,
    IQNetworkTaskStatusFailed,
}IQNetworkTaskStatus;

///--------------------------
/// @name Notifications
///--------------------------

/**
 Netowrk task finished either by success or failure
 */
extern NSString* _Nonnull const IQNetworkTaskDidFinishNotification;



@interface IQNetworkTask : NSObject
{
    @protected
    IQNetworkTaskStatus _status;
    CGFloat _downloadProgress;
    CGFloat _uploadProgress;
    
    __block IQURLConnection* _Nullable _connection;
    NSData* _Nullable _dataToResume;

    NSMutableSet* _Nonnull _statusChangeTargets;
    NSMutableSet* _Nonnull _downloadProgressTargets;
    NSMutableSet* _Nonnull _uploadProgressTargets;
    NSMutableSet* _Nonnull _completionTargets;
}

-(instancetype _Nonnull)initWithRequest:(NSURLRequest* _Nonnull)request;

/**
 Current status of network request
 */
@property(nonatomic, readonly) IQNetworkTaskStatus status;

/**
 Request to process by server
 */
@property(nonnull, nonatomic, readonly) NSURLRequest*request;

/**
 Upload progress of request
 */
@property(nonatomic, assign, readonly) CGFloat uploadProgress;

/**
 Download progress of request
 */
@property(nonatomic, assign, readonly) CGFloat downloadProgress;



///--------------------------
/// @name Callback Register
///--------------------------

/**
 Status Update
 */
- (void)addStatusUpdateTarget:(id _Nonnull)target action:(SEL _Nonnull)action;
- (void)removeStatusUpdateTarget:(id _Nonnull)target action:(SEL _Nonnull)action;

/**
 Download Progress
 */
- (void)addDownloadProgressTarget:(id _Nonnull)target action:(SEL _Nonnull)action;
- (void)removeDownloadProgressTarget:(id _Nonnull)target action:(SEL _Nonnull)action;

/**
 Upload Progress
 */
- (void)addUploadProgressTarget:(id _Nonnull)target action:(SEL _Nonnull)action;
- (void)removeUploadProgressTarget:(id _Nonnull)target action:(SEL _Nonnull)action;

/**
 Network task completion
 */
- (void)addCompletionTarget:(id _Nonnull)target action:(SEL _Nonnull)action;
- (void)removeCompletionTarget:(id _Nonnull)target action:(SEL _Nonnull)action;



///--------------------------
/// @name Request Handling
///--------------------------

-(void)start;
-(void)pause;
-(void)resume;
-(void)cancel;



///--------------------------
/// @name Subclass
///--------------------------

/**
 Subclass can optionally implement this method to change response according to needs.
 */
-(void)handleResponseData:(NSData * _Nullable * _Nullable)data error:(NSError * _Nullable * _Nullable)error;

@end
