//
//  ViewModel.swift
//  JikanTop
//
//  Created by Eric Hsu on 2021/12/10.
//

import MoyaSugar
import ProgressHUD
import RxCocoa
import RxSwift

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

        Observable
            .merge(
                state.selectedType.map { _ in },
                state.selectedSubType.map { _ in }
            )
            .debounce(.microseconds(100), scheduler: MainScheduler.instance)
            .bind(with: self) { `self`, _ in
                self.state.items.accept([])
                self.state.lastPage.accept(1)
            }
            .disposed(by: bag)

        state.selectedType
            .map { _ in nil }
            .bind(to: state.selectedSubType)
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
        provider.rx.request(
            .topItems(
                type: state.selectedType.value,
                subtype: state.selectedSubType.value,
                page: state.lastPage.value
            )
        )
        .map([TopItem].self, atKeyPath: "top")
        .subscribe(
            with: self,
            onSuccess: { `self`, items in
                self.state.items.accept(self.state.items.value + items)
            },
            onFailure: { _, error in
                print(error)
                ProgressHUD.showFailed(error.localizedDescription)
            }
        )
        .disposed(by: bag)
    }

    // MARK: Private

    private let provider: MoyaSugarProvider<JikanTarget>
    private let bag = DisposeBag()
}

extension ViewModel {
    struct State {
        let items = BehaviorRelay<[TopItem]>(value: [])
        let lastPage = BehaviorRelay<Int>(value: 1)
        let selectedType = BehaviorRelay<ItemType>(value: .anime)
        let selectedSubType = BehaviorRelay<ItemSubtype?>(value: nil)
    }

    struct Event {
        let didScrollBottom = PublishRelay<Void>()
        let flagTapped = PublishRelay<TopItem>()
    }
}
