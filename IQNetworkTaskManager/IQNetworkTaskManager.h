//
//  IQNetworkTaskManager.h
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
#import "IQNetworkTask.h"

@interface IQNetworkTaskManager : NSObject

///--------------------------
/// @name Singleton Instance
///--------------------------

+(instancetype)sharedManager;

///--------------------------
/// @name Network Tasks
///--------------------------

/**
 Add network task to the queue
 */
-(void)addTask:(IQNetworkTask*)task;

/**
 Remove network task to the queue
 */
-(void)removeTask:(IQNetworkTask*)task;

/**
 Tasks in current queue
 */
-(NSArray*)tasks;

///--------------------------
/// @name Subclasses only
///--------------------------

/**
 If you subclass IQNetworkTaskManager, then you can also provide your own networkClass method which should be a subclass of IQNetworkTask
 */
+(Class)networkClass;

@end
