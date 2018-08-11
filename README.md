# MulticastDelegator
> A Cocoa Touch Framework with MulticastDelegator Class to Establish a 1-to-many Relationship of Delegator to Delegate. 
Compatible with Swift (Objects only) and Objective-C.

# What is this?
The MulticastDelegator class can be used to establish a pattern of delegation that is a variation on the typical [Cocoa delegate design pattern](https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_delegates_to_customize_object_behavior). Specifically, instead of a one-to-one relationship from delegator to delegate, a one-to-many relationship is used.

* The MulticastDelegator has one or more delegates. They are maintained via a set of weak references (implemented with an [NSHashTable of weak objects](https://developer.apple.com/documentation/foundation/nshashtable/1412241-weakobjectshashtable)).
* The delegates are not required to remove themselves from the MulticastDelegator's set as the MulticastDelegator holds only weak references to its delegates.


# Swift Usage
```Swift
// MARK: - Define a protocol
// Protocol must inherit from AnyObject to maintain compatibility with Objective-C
@objc protocol MyProtocol: AnyObject {
    @objc func requiredMethodWithBoolean(_ boolean: Bool)
    @objc optional func optionalMethod()
}

// MARK: - Define objects that conform to the protocol
class MyFirstProtocolObject: MyProtocol {
    func requiredMethodWithBoolean(_ boolean: Bool) {
        
    }
}

class MySecondProtocolObject: MyProtocol {
    func requiredMethodWithBoolean(_ boolean: Bool) {
        
    }
    
    func optionalMethod() {
        
    }
}

// MARK: - Usage
func usageExample() {
    
    let delegator = MulticastDelegator<MyProtocol>()
    let firstDelegate = MyFirstProtocolObject()
    let secondDelegate = MySecondProtocolObject()
    delegator.addDelegate(firstDelegate)
    delegator.addDelegate(secondDelegate)
    
    delegator.invokeDelegates { (delegate: MyProtocol) in
        delegate.requiredMethodWithBoolean(true)
    }
    
    delegator.invokeDelegates { (delegate: MyProtocol) in
        delegate.optionalMethod?()
    }
}

```

# Objective-C Usage
```Objective-C
#pragma mark - Define a Protocol
@protocol MyProtocol <NSObject>

- (void)requiredMethodWithBoolean:(BOOL)boolean;

@optional
- (void)optionalMethod;

@end

#pragma mark - Define objects that conform to the protocol
@interface MyFirstProtocolObject: NSObject <MyProtocol>

@end

@implementation MyFirstProtocolObject

- (void)requiredMethodWithBoolean:(BOOL)boolean
{
    
}

- (void)optionalMethod
{
    
}

@end

@interface MySecondProtocolObject: NSObject <MyProtocol>

@end

@implementation MySecondProtocolObject

- (void)requiredMethodWithBoolean:(BOOL)boolean
{
    
}

@end

#pragma mark - Usage
void usageExample()
{
    MulticastDelegator<id<MyProtocol>> *delegator = [MulticastDelegator new];
    id<MyProtocol> firstDelegate = [MyFirstProtocolObject new];
    id<MyProtocol> secondDelegate = [MySecondProtocolObject new];
    [delegator addDelegate:firstDelegate];
    [delegator addDelegate:secondDelegate];
    
    [delegator invokeDelegates:^(id<MyProtocol> delegate) {
        [delegate requiredMethodWithBoolean:YES];
    }];
    
    [delegator invokeDelegates:^(id<MyProtocol> delegate) {
        if ([delegate respondsToSelector:@selector(optionalMethod)])
        {
            [delegate optionalMethod];
        }
    }];
}

```
