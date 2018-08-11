//
//  MulticastDelegatorTests.swift
//  MulticastDelegatorTests
//
//  Created by Eric Fisher on 8/10/18.
//  Copyright © 2018 merrygobyebye. All rights reserved.
//

import XCTest

@objc fileprivate protocol MyProtocol: AnyObject {
    @objc optional func foo()
    @objc optional func fooWithBar(_ bar: String, baz _: String)
}

fileprivate class MyProtocolObject: MyProtocol {
    
    fileprivate var fooInvocations: UInt = 0
    fileprivate var bar: String?
    fileprivate var baz: String?
    
    func foo() {
        fooInvocations += 1
    }
    
    func fooWithBar(_ bar: String, baz: String) {
        self.bar = bar;
        self.baz = baz;
    }
}

fileprivate class MyProtocolObjectOptional: MyProtocol {
    
    fileprivate var fooInvocations: UInt = 0
    fileprivate var bar: String?
    fileprivate var baz: String?
    
}

fileprivate class NotMyProtocolObject {
    
    fileprivate var fooInvocations: UInt = 0
    fileprivate var bar: String?
    fileprivate var baz: String?
    
}

class MulticastDelegatorTests: XCTestCase {
    
    private var delegator: MulticastDelegator<MyProtocol>!
    
    override func setUp() {
        super.setUp()
        delegator = MulticastDelegator<MyProtocol>()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNilAfterDealloc() {
        
        weak var myWeakProtocol1: MyProtocolObject?
        weak var myWeakProtocol2: MyProtocolObject?
        
        autoreleasepool { () -> () in
            let myStrongProtocol1 = MyProtocolObject()
            myWeakProtocol1 = myStrongProtocol1
            let myStrongProtocol2 = MyProtocolObject()
            myWeakProtocol2 = myStrongProtocol2
            
            delegator.addDelegate(myStrongProtocol1)
            delegator.addDelegate(myStrongProtocol2)
            
            XCTAssertEqual(delegator.delegates.count, 2)
            XCTAssertNotNil(myWeakProtocol1)
            XCTAssertNotNil(myWeakProtocol2)
        }
        
        let nilPredicate = NSPredicate(format: "self = nil", argumentArray: nil)
        let nilProtocolExpectation1 = self.expectation(for: nilPredicate, evaluatedWith: myWeakProtocol1 as Any, handler: nil)
        let nilProtocolExpectation2 = self.expectation(for: nilPredicate, evaluatedWith: myWeakProtocol2 as Any, handler: nil)
        self.wait(for: [nilProtocolExpectation1, nilProtocolExpectation2], timeout: 4.0)
        
        XCTAssertEqual(self.delegator.delegates.count, 0)
    }
    
    func testAddDelegate() {
        let myProtocol1 = MyProtocolObject()
        let myProtocol2 = MyProtocolObject()
        
        delegator.addDelegate(myProtocol1)
        delegator.addDelegate(myProtocol1)
        delegator.addDelegate(myProtocol2)
        
        XCTAssertEqual(self.delegator.delegates.count, 2)
        
        var loopCount = 0;
        self.delegator.delegates.forEach({ (delegate) in
            loopCount += 1
            XCTAssertNotNil(delegate)
        })
        XCTAssertEqual(loopCount, 2);
    }
    
    func testRemoveDelegate() {
        let myProtocol1 = MyProtocolObject()
        let myProtocol2 = MyProtocolObject()
        
        delegator.addDelegate(myProtocol1)
        delegator.addDelegate(myProtocol2)
        
        XCTAssertEqual(self.delegator.delegates.count, 2)
        
        self.delegator.removeDelegate(myProtocol1)
        self.delegator.removeDelegate(myProtocol2)
        XCTAssertEqual(self.delegator.delegates.count, 0)
        
        self.delegator.removeDelegate(myProtocol1)
        self.delegator.removeDelegate(myProtocol2)
        XCTAssertEqual(self.delegator.delegates.count, 0)
    }
    
    func testInvokeDelegates() {
        let myProtocol1 = MyProtocolObject()
        let myProtocol2 = MyProtocolObject()
        let myProtocol3 = MyProtocolObjectOptional()
        
        delegator.addDelegate(myProtocol1)
        delegator.addDelegate(myProtocol2)
        delegator.addDelegate(myProtocol3)
        
        self.delegator.invokeDelegates { (delegate: MyProtocol) in
            delegate.foo?()
        }
        
        self.delegator.invokeDelegates { (delegate: MyProtocol) in
            delegate.fooWithBar?("bar", baz: "baz")
        }
        
        XCTAssertEqual(myProtocol1.fooInvocations, 1);
        XCTAssertEqual(myProtocol1.bar, "bar");
        XCTAssertEqual(myProtocol1.baz, "baz");
        
        XCTAssertEqual(myProtocol2.fooInvocations, 1);
        XCTAssertEqual(myProtocol2.bar, "bar");
        XCTAssertEqual(myProtocol2.baz, "baz");
        
        XCTAssertEqual(myProtocol3.fooInvocations, 0);
        XCTAssertNil(myProtocol3.bar);
        XCTAssertNil(myProtocol3.baz);
    }
    
    func testNilDelegatesRemovedAutomaticallyAndNotInvoked() {
        
        let myProtocol1 = MyProtocolObject()
        self.delegator.addDelegate(myProtocol1)
        
        weak var myWeakProtocol: MyProtocolObject?
        autoreleasepool { () -> () in
            let myProtocol2 = MyProtocolObject()
            myWeakProtocol = myProtocol2
            delegator.addDelegate(myProtocol2)
        }
        
        let nilPredicate = NSPredicate(format: "self = nil", argumentArray: nil)
        let nilProtocolExpectation = self.expectation(for: nilPredicate, evaluatedWith: myWeakProtocol as Any, handler: nil)
        self.wait(for: [nilProtocolExpectation], timeout: 4.0)
        
        XCTAssertEqual(self.delegator.delegates.count, 1)
        
        var invocationCount = 0
        self.delegator.invokeDelegates { (delegate: MyProtocol) in
            invocationCount += 1
            delegate.foo?()
        }
        
        XCTAssertEqual(invocationCount, 1)
    }
}
