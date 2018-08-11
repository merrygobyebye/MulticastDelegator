//
//  MulticastDelegatorTests.m
//  MulticastDelegatorTests
//
//  Created by Eric Fisher on 8/10/18.
//  Copyright © 2018 merrygobyebye. All rights reserved.
//

@import XCTest;
#import "MulticastDelegatorFramework.h"

@protocol MyProtocol <NSObject>

@optional
- (void)foo;
- (void)fooWithBar:(NSString *)bar baz:(NSString *)baz;

@end

@interface MyProtocolObject: NSObject <MyProtocol>

- (void)foo;
- (void)fooWithBar:(NSString *)bar baz:(NSString *)baz;

@property (nonatomic, assign) NSUInteger fooInvocations;
@property (nonatomic, strong) NSString *bar;
@property (nonatomic, strong) NSString *baz;

@end

@implementation MyProtocolObject

- (void)foo
{
    ++self.fooInvocations;
}

- (void)fooWithBar:(NSString *)bar baz:(NSString *)baz
{
    self.bar = bar;
    self.baz = baz;
}

@end

@interface MyProtocolObjectOptional: NSObject <MyProtocol>

@property (nonatomic, assign) NSUInteger fooInvocations;
@property (nonatomic, strong) NSString *bar;
@property (nonatomic, strong) NSString *baz;

@end

@implementation MyProtocolObjectOptional

@end

@interface MulticastDelegator (Test)

@property (nonatomic, strong) NSHashTable *_delegates;

@end

@interface MulticastDelegatorFrameworkTests : XCTestCase

@property (nonatomic, strong) MulticastDelegator<id<MyProtocol>> *delegator;

@end

@implementation MulticastDelegatorFrameworkTests

- (void)setUp
{
    [super setUp];
    
    self.delegator = [MulticastDelegator<MyProtocol> new];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testNilAfterDealloc
{
    __weak __block MyProtocolObject *myWeakProtocol1;
    __weak __block MyProtocolObject *myWeakProtocol2;
    
    @autoreleasepool {
        
        MyProtocolObject *myStrongProtocol1 = [MyProtocolObject new];
        myWeakProtocol1 = myStrongProtocol1;
        MyProtocolObject *myStrongProtocol2 = [MyProtocolObject new];
        myWeakProtocol2 = myStrongProtocol2;
        
        [self.delegator addDelegate:myStrongProtocol1];
        [self.delegator addDelegate:myStrongProtocol2];
        
        XCTAssertEqual(self.delegator.delegates.count, 2);
        XCTAssertNotNil(myWeakProtocol1);
        XCTAssertNotNil(myWeakProtocol2);
        for (id<MyProtocol> protocolObj in self.delegator.delegates)
        {
            XCTAssertNotNil(protocolObj);
        }
    }
    
    NSPredicate *nilPredicate = [NSPredicate predicateWithFormat:@"self = nil"];
    XCTestExpectation *nilProtocolExpectation1 = [self expectationForPredicate:nilPredicate evaluatedWithObject:myWeakProtocol1 handler:nil];
    XCTestExpectation *nilProtocolExpectation2 = [self expectationForPredicate:nilPredicate evaluatedWithObject:myWeakProtocol2 handler:nil];
    [self waitForExpectations:@[nilProtocolExpectation1, nilProtocolExpectation2] timeout:4.0];

    XCTAssertEqual(self.delegator._delegates.count, 2);
    XCTAssertEqual(self.delegator.delegates.count, 0);
}

- (void)testAddDelegate
{
    MyProtocolObject *myProtocol1 = [MyProtocolObject new];
    MyProtocolObject *myProtocol2 = [MyProtocolObject new];
    
    [self.delegator addDelegate:myProtocol1];
    [self.delegator addDelegate:myProtocol1];
    [self.delegator addDelegate:myProtocol2];
    
    XCTAssertEqual(self.delegator.delegates.count, 2);
    NSUInteger loopCount = 0;
    for (id<MyProtocol> protocolObj in self.delegator.delegates)
    {
        XCTAssertNotNil(protocolObj);
        ++loopCount;
    }
    
    XCTAssertEqual(loopCount, 2);
}

- (void)testRemoveDelegate
{
    MyProtocolObject *myProtocol1 = [MyProtocolObject new];
    MyProtocolObject *myProtocol2 = [MyProtocolObject new];
    
    [self.delegator addDelegate:myProtocol1];
    [self.delegator addDelegate:myProtocol1];
    [self.delegator addDelegate:myProtocol2];
    
    XCTAssertEqual(self.delegator.delegates.count, 2);
    NSUInteger loopCount = 0;
    for (id<MyProtocol> protocolObj in self.delegator.delegates)
    {
        XCTAssertNotNil(protocolObj);
        ++loopCount;
    }
    XCTAssertEqual(loopCount, 2);
    
    [self.delegator removeDelegate:myProtocol1];
    [self.delegator removeDelegate:myProtocol2];
    XCTAssertEqual(self.delegator._delegates.count, 0);
    XCTAssertEqual(self.delegator.delegates.count, 0);
    
    [self.delegator removeDelegate:myProtocol1];
    [self.delegator removeDelegate:myProtocol2];
    XCTAssertEqual(self.delegator._delegates.count, 0);
    XCTAssertEqual(self.delegator.delegates.count, 0);
}

- (void)testInvokeDelegates
{
    MyProtocolObject *myProtocol1 = [MyProtocolObject new];
    MyProtocolObject *myProtocol2 = [MyProtocolObject new];
    MyProtocolObjectOptional *myProtocol3 = [MyProtocolObjectOptional new];
    
    [self.delegator addDelegate:myProtocol1];
    [self.delegator addDelegate:myProtocol2];
    [self.delegator addDelegate:myProtocol3];
    
    [self.delegator invokeDelegates:^(id<MyProtocol> delegate) {
        
        if ([delegate respondsToSelector:@selector(foo)])
        {
            [(id<MyProtocol>)delegate foo];
        }
    }];
    
    
    [self.delegator invokeDelegates:^(id<MyProtocol> delegate) {
        
        if ([delegate respondsToSelector:@selector(fooWithBar:baz:)])
        {
            [(id<MyProtocol>)delegate fooWithBar:@"bar" baz:@"baz"];
        }
    }];
    
    XCTAssertEqual(myProtocol1.fooInvocations, 1);
    XCTAssertEqualObjects(myProtocol1.bar, @"bar");
    XCTAssertEqualObjects(myProtocol1.baz, @"baz");
    
    XCTAssertEqual(myProtocol2.fooInvocations, 1);
    XCTAssertEqualObjects(myProtocol2.bar, @"bar");
    XCTAssertEqualObjects(myProtocol2.baz, @"baz");
    
    XCTAssertEqual(myProtocol3.fooInvocations, 0);
    XCTAssertNil(myProtocol3.bar);
    XCTAssertNil(myProtocol3.baz);
}

- (void)testNilDelegatesRemovedAutomaticallyAndNotInvoked
{
    MyProtocolObject *myProtocol1 = [MyProtocolObject new];
    [self.delegator addDelegate:myProtocol1];
    
    __weak __block MyProtocolObject *myWeakProtocol;
    @autoreleasepool {
        
        MyProtocolObject *myProtocol2 = [MyProtocolObject new];
        myWeakProtocol = myProtocol2;
        [self.delegator addDelegate:myProtocol2];
    }
    
    NSPredicate *nilPredicate = [NSPredicate predicateWithFormat:@"self = nil"];
    XCTestExpectation *nilProtocolExpectation = [self expectationForPredicate:nilPredicate evaluatedWithObject:myWeakProtocol handler:nil];
    [self waitForExpectations:@[nilProtocolExpectation] timeout:4.0];
    
    XCTAssertEqual(self.delegator._delegates.count, 2);
    XCTAssertEqual(self.delegator.delegates.count, 1);
    
    __block NSUInteger invocationCount = 0;
    [self.delegator invokeDelegates:^(id<MyProtocol> delegate) {
        
        ++invocationCount;
        if ([delegate respondsToSelector:@selector(foo)])
        {
            [(id<MyProtocol>)delegate foo];
        }
    }];
    
    XCTAssertEqual(invocationCount, 1);
}

@end
