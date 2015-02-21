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
    XCTAssert(s.error() == nil)
  }

  func testFailureReturnsError() {
    let f: Result<Int> = failure(self.err)
    XCTAssertEqual(f.error() as NSError, self.err)
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
    XCTAssertEqual(y.error() as NSError, self.err)
  }

  func testMapSuccessNewType() {
    let x = success("abcd")
    let y = x.map { countElements($0) }
    XCTAssertEqual(y.value()!, 4)
  }

  func testMapFailureNewType() {
    let x: Result<String> = failure(self.err)
    let y = x.map { countElements($0) }
    XCTAssertEqual(y.error() as NSError, self.err)
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
    XCTAssertEqual(y.error() as NSError, self.err)
  }

  func testFlatMapFailureSuccess() {
    let x: Result<Int> = failure(self.err2)
    let y = x.flatMap(doubleSuccess)
    XCTAssertEqual(y.error() as NSError, self.err2)
  }

  func testFlatMapFailureFailure() {
    let x: Result<Int> = failure(self.err2)
    let y = x.flatMap(doubleFailure)
    XCTAssertEqual(y.error() as NSError, self.err2)
  }

  func testDescriptionSuccess() {
    let x = success(42)
    XCTAssertEqual(x.description, "Success: 42")
  }

  func testDescriptionFailure() {
    let x: Result<String> = failure()
    XCTAssert(x.description.hasPrefix("Failure: Error Domain= Code=0 "))
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
