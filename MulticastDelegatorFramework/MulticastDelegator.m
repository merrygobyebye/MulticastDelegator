//
//  MulticastDelegaor.m
//  MulticastDelegator
//
//  Created by Eric Fisher on 8/10/18.
//  Copyright © 2018 merrygobyebye. All rights reserved.
//

@import Foundation;
#import "MulticastDelegator.h"

@interface MulticastDelegator<ObjectType> ()

@property (nonatomic, strong) NSHashTable<ObjectType> *_delegates;

@end

@implementation MulticastDelegator

#pragma mark - Init

- (instancetype)init
{
    if (self = [super init])
    {
        __delegates = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}


#pragma mark - Accessors

- (NSArray *)delegates
{
    return self._delegates.allObjects;
}


#pragma mark - Public

- (void)addDelegate:(id)delegate
{
    [self._delegates addObject:delegate];
}

- (void)removeDelegate:(id)delegate
{
    [self._delegates removeObject:delegate];
}

- (void)invokeDelegates:(void (^ __nonnull)(__nonnull id))invocation
{
    for (id delegate in self.delegates)
    {
        invocation(delegate);
    }
}

@end

