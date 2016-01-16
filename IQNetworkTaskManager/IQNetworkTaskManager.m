//
//  IQNetworkTaskManager.m
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

#import "IQNetworkTaskManager.h"

@implementation IQNetworkTaskManager
{
@protected
    NSMutableSet *currentTasks;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        currentTasks = [[NSMutableSet alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskDidFinishNotification:) name:IQNetworkTaskDidFinishNotification object:nil];
    }
    return self;
}

-(NSArray*)tasks
{
    return [currentTasks allObjects];
}

+(instancetype)sharedManager
{
    static NSMutableDictionary *sharedDictionary;
    
    if (sharedDictionary == nil)    sharedDictionary = [[NSMutableDictionary alloc] init];
    
    id sharedObject = [sharedDictionary objectForKey:NSStringFromClass([self class])];
    
    if (sharedObject == nil)
    {
        @synchronized(self) {
            
            //Again trying (May be set from another thread)
            sharedObject = [sharedDictionary objectForKey:NSStringFromClass([self class])];
            
            if (sharedObject)
            {
                return sharedObject;
            }
            else
            {
                sharedObject = [[self alloc] init];
                
                [sharedDictionary setObject:sharedObject forKey:NSStringFromClass([self class])];
            }
        }
    }
    
    return sharedObject;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addTask:(IQNetworkTask*)task
{
    [currentTasks addObject:task];
    [task start];
}

-(void)removeTask:(IQNetworkTask*)task
{
    [task cancel];
    [currentTasks removeObject:task];
}

-(void)downloadTaskDidFinishNotification:(NSNotification*)notification
{
    [currentTasks removeObject:notification.object];
}

+(Class)networkClass
{
    return [IQNetworkTask class];
}

@end
