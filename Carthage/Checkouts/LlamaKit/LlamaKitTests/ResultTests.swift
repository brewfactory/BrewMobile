//
//  LlamaKitTests.swift
//  LlamaKitTests
//
//  Created by Rob Napier on 9/9/14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import Foundation
import LlamaKit
import XCTest

class ResultTests: XCTestCase {
  let err = NSError(domain: "", code: 11, userInfo: nil)
  let err2 = NSError(domain: "", code: 12, userInfo: nil)

  func testSuccessIsSuccess() {
    let s = success(42)
    XCTAssertTrue(s.isSuccess())
  }

  func testFailureIsNotSuccess() {
    let f: Result<Bool> = failure()
    XCTAssertFalse(f.isSuccess())
  }

  func testSuccessReturnsValue() {
    let s = success(42)
    XCTAssertEqual(s.value()!, 42)
  }

  func testSuccessReturnsNoError() {
    let s = success(42)
    XCTAssertNil(s.error())
  }

  func testFailureReturnsError() {
    let f: Result<Int> = failure(self.err)
    XCTAssertEqual(f.error()!, self.err)
  }

  func testFailureReturnsNoValue() {
    let f: Result<Int> = failure(self.err)
    XCTAssertNil(f.value())
  }

  func testMapSuccessUnaryOperator() {
    let x = success(42)
    let y = x.map(-)
    XCTAssertEqual(y.value()!, -42)
  }

  func testMapFailureUnaryOperator() {
    let x: Result<Int> = failure(self.err)
    let y = x.map(-)
    XCTAssertNil(y.value())
    XCTAssertEqual(y.error()!, self.err)
  }

  func testMapSuccessNewType() {
    let x = success("abcd")
    let y = x.map { countElements($0) }
    XCTAssertEqual(y.value()!, 4)
  }

  func testMapFailureNewType() {
    let x: Result<String> = failure(self.err)
    let y = x.map { countElements($0) }
    XCTAssertEqual(y.error()!, self.err)
  }

  func doubleSuccess(x: Int) -> Result<Int> {
    return success(x * 2)
  }

  func doubleFailure(x: Int) -> Result<Int> {
    return failure(self.err)
  }

  func testFlatMapSuccessSuccess() {
    let x = success(42)
    let y = x.flatMap(doubleSuccess)
    XCTAssertEqual(y.value()!, 84)
  }

  func testFlatMapSuccessFailure() {
    let x = success(42)
    let y = x.flatMap(doubleFailure)
    XCTAssertEqual(y.error()!, self.err)
  }

  func testFlatMapFailureSuccess() {
    let x: Result<Int> = failure(self.err2)
    let y = x.flatMap(doubleSuccess)
    XCTAssertEqual(y.error()!, self.err2)
  }

  func testFlatMapFailureFailure() {
    let x: Result<Int> = failure(self.err2)
    let y = x.flatMap(doubleFailure)
    XCTAssertEqual(y.error()!, self.err2)
  }

  func testDescriptionSuccess() {
    let x = success(42)
    XCTAssertEqual(x.description, "Success: 42")
  }

  func testDescriptionFailure() {
    let x: Result<String> = failure()
    XCTAssertEqual(x.description, "Failure: Error Domain= Code=0 \"The operation couldn’t be completed. ( error 0.)\"")
  }

  func testEqualitySuccessSuccessEqual() {
    let x = success(42)
    let y = success(42)
    XCTAssertTrue(x == y)
  }

  func testEqualitySuccessSuccessNotEqual() {
    let x = success(42)
    let y = success(43)
    XCTAssertTrue(x != y)
  }

  func testEqualitySuccessFailure() {
    let x = success(42)
    let y: Result<Int> = failure()
    XCTAssertTrue(x != y)
  }

  func testEqualityFailureSuccess() {
    let x = success(42)
    let y: Result<Int> = failure()
    XCTAssertTrue(y != x)
  }

  func testEqualityFailureFailureEqual() {
    let x: Result<Int> = failure(err)
    let y: Result<Int> = failure(err)
    XCTAssertTrue(x == y)
  }

  func testEqualityFailureFailureNotEqual() {
    let x: Result<Int> = failure(err)
    let y: Result<Int> = failure(err2)
    XCTAssertTrue(x != y)
  }

  func testCoalesceSuccess() {
    let x = success(42) ?? 43
    XCTAssertEqual(x, 42)
  }

  func testCoalesceFailure() {
    let x = failure() ?? 43
    XCTAssertEqual(x, 43)
  }
}
