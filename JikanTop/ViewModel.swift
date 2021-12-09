//
//  ViewModel.swift
//  JikanTop
//
//  Created by Eric Hsu on 2021/12/10.
//

import RxCocoa
import RxSwift
import MoyaSugar

// MARK: - ViewModel

final class ViewModel {
    // MARK: Lifecycle

    init(_ provider: MoyaSugarProvider<JikanTarget> = API) {
        self.provider = provider
        event.didScrollBottom
            .withLatestFrom(state.lastPage)
            .map { $0 + 1 }
            .bind(to: state.lastPage)
            .disposed(by: bag)

        state.lastPage
            .bind(with: self) { `self`, page in
                self.fetchItems(at: page)
            }
            .disposed(by: bag)
    }

    // MARK: Internal

    let state = State()
    let event = Event()

    func fetchItems(at page: Int) {
        provider.rx.request(.topItems(type: .anime, subtype: nil, page: nil))
            .map([TopItem].self, atKeyPath: "top")
            .subscribe(
                with: self,
                onSuccess: { `self`, items in
                    self.state.items.accept(items)
                },
                onFailure: { _, _ in })
            .disposed(by: bag)
    }

    // MARK: Private

    private let provider: MoyaSugarProvider<JikanTarget>
    private let bag = DisposeBag()
}

extension ViewModel {
    struct State {
        let items = BehaviorRelay<[TopItem]>(value: [])
        let lastPage = BehaviorRelay<Int>(value: 0)
    }

    struct Event {
        let didScrollBottom = PublishRelay<Void>()
    }
}
