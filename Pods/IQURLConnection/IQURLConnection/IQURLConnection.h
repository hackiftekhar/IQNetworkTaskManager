//
//  IQURLConnection.h
// https://github.com/hackiftekhar/IQURLConnection
// Copyright (c) 2013-16 Iftekhar Qurashi.
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

/**
 `IQURLConnectionDataCompletionBlock`
 Used for sending callback when request is completed or failed.
 
 `IQURLConnectionResponseBlock`
 Used for sending response callback.
 
 `IQURLConnectionProgressBlock`
 Used for sending data upload/download callbacks.
 */
typedef void (^IQURLConnectionDataCompletionBlock)(NSData* _Nullable result, NSError* _Nullable error);
typedef void (^IQURLConnectionResponseBlock)(NSHTTPURLResponse* _Nullable response);
typedef void (^IQURLConnectionProgressBlock)(CGFloat progress);

#import <Foundation/NSURLConnection.h>

@interface IQURLConnection : NSURLConnection

///--------------------------
/// @name Initialization
///--------------------------

/**
 Send an asynchronous request, you can optionally register for response, upload, download and completionHandlers. This method automatically triggers `start` method.
 */
+ (nonnull instancetype)sendAsynchronousRequest:(nonnull NSMutableURLRequest *)request
                                  responseBlock:(nullable IQURLConnectionResponseBlock)responseBlock
                            uploadProgressBlock:(nullable IQURLConnectionProgressBlock)uploadProgress
                          downloadProgressBlock:(nullable IQURLConnectionProgressBlock)downloadProgress
                              completionHandler:(nullable IQURLConnectionDataCompletionBlock)completion;

/**
 Initialize an asynchronous request, you can optionally register for response, upload, download and completionHandlers. This method doesn't automatically triggers `start` method, `start` method should be triggered manually according to need.
 */
- (nonnull instancetype)initWithRequest:(nonnull NSMutableURLRequest *)request
                             resumeData:(nullable NSData*)dataToResume
                          responseBlock:(nullable IQURLConnectionResponseBlock)responseBlock
                    uploadProgressBlock:(nullable IQURLConnectionProgressBlock)uploadProgress
                  downloadProgressBlock:(nullable IQURLConnectionProgressBlock)downloadProgress
                        completionBlock:(nullable IQURLConnectionDataCompletionBlock)completion;

////Functions of NSURLConnection start and cancel
- (void)start;
- (void)cancel;



///--------------------------
/// @name Request
///--------------------------

/**
 Upload progress of request.
 */
@property(nonatomic, assign, readonly) CGFloat uploadProgress;

/**
 Upload progress callback block.
 */
@property(nullable, nonatomic, strong) IQURLConnectionProgressBlock uploadProgressBlock;

/**
 totalBytesWritten of upload request.
 */
@property(nonatomic, assign, readonly) NSInteger totalBytesWritten;

/**
 totalBytesExpectedToWrite of upload request.
 */
@property(nonatomic, assign, readonly) NSInteger totalBytesExpectedToWrite;



///--------------------------
/// @name Response
///--------------------------

/**
 HTTP Response by the request. It will be nil before getting a response.
 */
@property(nullable, nonatomic, strong, readonly) NSHTTPURLResponse *response;

/**
 Response callback block.
 */
@property(nullable, nonatomic, strong) IQURLConnectionResponseBlock responseBlock;

/**
 Download progress of request.
 */
@property(nonatomic, assign, readonly) CGFloat downloadProgress;

/**
 Download progress callback block.
 */
@property(nullable, nonatomic, strong) IQURLConnectionProgressBlock downloadProgressBlock;

/**
 totalBytesReceived of download request.
 */
@property(nonatomic, assign, readonly) NSInteger totalBytesReceived;

/**
 Expected content length of response data.
 */
@property(nonatomic, assign, readonly) NSInteger expectedContentLength;



///--------------------------
/// @name Response Completion
///--------------------------

/**
 Response data of request.
 */
@property(nullable, nonatomic, strong, readonly) NSData *responseData;

/**
 Error object of request.
 */
@property(nullable, nonatomic, strong, readonly) NSError *error;

/**
 Download progress callback block.
 */
@property(nullable, nonatomic, strong) IQURLConnectionDataCompletionBlock dataCompletionBlock;


///--------------------------
/// @name Cache
///--------------------------

/**
 Previoiusly Cached response of the request.
 */
@property(nullable, nonatomic, strong, readonly) NSCachedURLResponse *cachedURLResponse;

@end
