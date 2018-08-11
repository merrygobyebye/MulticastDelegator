//
//  MulticastDelegator.h
//  MulticastDelegatorFramework
//
//  Created by Eric Fisher on 8/11/18.
//  Copyright © 2018 merrygobyebye. All rights reserved.
//

@import Foundation;

/*!
 @brief An object that holds a collection (set) of weak references to objects.
 
 @discussion The MulticastDelegator can be used as a variation of the Cocoa delegator design pattern: it allows for a 1-to-many
 relationship from delegator to delegate.
 */
@interface MulticastDelegator<ObjectType>: NSObject

/*!
 @brief An array of all of the delegates in the MulticastDelegator that have not been automatically released.
 
 @discussion Consider removing this property in production. It may be a poor architectural choice if objects other than the
 MulticastDelegator itself need information about its delegates.
 */
@property (nonatomic, strong, readonly) NSArray<ObjectType> *delegates;

/*!
 @brief Adds a delegate to the MulticastDelegator.
 
 @discussion This function uses set semantics. That is, if this method is called with the same parameter many times, only one
 copy of that object will exist in the MulticastDelegator's list of delegates.
 */
- (void)addDelegate:(ObjectType)delegate;

/*!
 @brief Removes a delegate from the MulticastDelegator.
 
 @discussion It is not required to call this function for a delegate to be automatically released from memory and removed from the
 MulticastDelegator's list of delegates. This method should only be used in the case where an object is required to no longer receive
 messages from the MulticastDelegator.
 
 This function uses set semantics. That is, this method will do nothing if called with a parameter that is not in the
 MulticastDelegator's list of delegates.
 */
- (void)removeDelegate:(ObjectType)delegate;

/*!
 @brief Invokes all of the delegate objects that have not been automatically released.
 
 @discussion This function should be used to pass information from the MulticastDelegator to the delegates via their publicly
 available methods.
 
 @param invocation A block that takes in a non-null ObjectType to pass information from the MulticastDelegator to the ObjectType.
 */
- (void)invokeDelegates:(void (^ __nonnull)(__nonnull ObjectType))invocation;

@end
