//
//  JikanTargetTests.swift
//  JikanTopTests
//
//  Created by Eric Hsu on 2021/12/10.
//

import XCTest
@testable import JikanTop
import MoyaSugar
import RxSwift

class JikanTargetTests: XCTestCase {

    let sampleEndpointClosure = { (target: JikanTarget) -> Endpoint in
        Endpoint(url: URL(target: target).absoluteString,
                 sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                 method: target.method,
                 task: target.task,
                 httpHeaderFields: target.headers)
    }

    lazy var stubbingProvider = MoyaProvider<JikanTarget>(
        endpointClosure: sampleEndpointClosure,
        stubClosure: MoyaProvider.immediatelyStub
    )
    let bag = DisposeBag()


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTopItems() throws {
        let expect = expectation(description: "Sample1 response decoding should not fail")
        stubbingProvider.rx.request(.topItems(type: .anime, subtype: nil, page: nil))
            .map([TopItem].self, atKeyPath: "top")
            .subscribe(
                onSuccess: { res in
                    XCTAssertEqual(res.first?.id, 48583)
                    XCTAssertEqual(res.first?.rank, 1)
                    XCTAssertEqual(res.last?.rank, 50)
                    XCTAssertEqual(res.count, 50)
                    expect.fulfill()
                },
                onFailure: { XCTFail("\($0)") }
            )
            .disposed(by: bag)
        waitForExpectations(timeout: 1, handler: nil)
    }

}

extension JikanTarget {
    var sampleData: Data {
        let bundle = Bundle(for: JikanTargetTests.self)
        switch self {
        case .topItems:
            let fileUrl = bundle.url(forResource: "Sample1", withExtension: "json")
            return try! Data(contentsOf: fileUrl!)
        }
    }
}
