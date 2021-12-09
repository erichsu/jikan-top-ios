//
//  JikanTopTests.swift
//  JikanTopTests
//
//  Created by Eric Hsu on 2021/12/10.
//

@testable import JikanTop
import MoyaSugar
import RxSwift
import RxTest
import XCTest

class JikanTopTests: XCTestCase {
    var scheduler: TestScheduler!
    let sampleEndpointClosure = { (target: JikanTarget) -> Endpoint in
        Endpoint(url: URL(target: target).absoluteString,
                 sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                 method: target.method,
                 task: target.task,
                 httpHeaderFields: target.headers)
    }

    lazy var stubbingProvider = MoyaSugarProvider<JikanTarget>(
        endpointClosure: sampleEndpointClosure,
        stubClosure: MoyaProvider.immediatelyStub
    )

    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScrollToNextPage() throws {
        let viewModel = ViewModel()
        XCTAssertEqual(viewModel.state.lastPage.value, 0)
        viewModel.event.didScrollBottom.accept(())
        XCTAssertEqual(viewModel.state.lastPage.value, 1)
    }

    func testCallAPIForNextPage() throws {
        let viewModel = ViewModel(stubbingProvider)
        let disposeBag = DisposeBag()

        // Scroll at bottom 3 times
        scheduler
            .createColdObservable([
                Recorded.next(100, ()),
                Recorded.next(200, ()),
                Recorded.next(300, ())
            ])
            .bind(to: viewModel.event.didScrollBottom)
            .disposed(by: disposeBag)

        let observer = scheduler.createObserver([TopItem].self)
        viewModel.state.items
            .bind(to: observer)
            .disposed(by: disposeBag)

        scheduler.start()
        // API should update items 4 times (initial load + next page load)
        XCTAssertEqual(observer.events.count, 3 + 1)
    }
}
