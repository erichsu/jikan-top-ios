//
//  ViewController.swift
//  JikanTop
//
//  Created by Eric Hsu on 2021/12/10.
//

import RxDataSources
import RxSwift
import SafariServices
import SnapKit
import SwiftyUserDefaults
import UIKit

// MARK: - ViewController

final class ViewController: UIViewController {
    // MARK: Internal

    typealias Section = SectionModel<Void, TopItem>

    let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindInput()
        bindOutput()
    }

    // MARK: Private

    private lazy var tableView = UITableView().then {
        $0.register(cellWithClass: TopItemCell.self)
    }

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Section>(
        configureCell: { _, tableView, index, item in
            let cell = tableView.dequeueReusableCell(withClass: TopItemCell.self, for: index)
            cell.setup(with: item, isFlag: Defaults.flagItems.contains(item.id))
            cell.flagButton.rx.tap
                .bind(with: self) { `self`, _ in
                    self.viewModel.event.flagTapped.accept(item)
                }
                .disposed(by: cell.bag)
            return cell
        }
    )

    private func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func bindInput() {
        tableView.rx.modelSelected(Section.Item.self)
            .compactMap(\.url)
            .bind(with: self) { `self`, url in
                let webView = SFSafariViewController(url: url)
                self.present(webView, animated: true)
            }
            .disposed(by: rx.disposeBag)
    }

    private func bindOutput() {
        Observable
            .merge(
                viewModel.event.flagTapped
                    .withLatestFrom(viewModel.state.items),
                viewModel.state.items.asObservable()
            )
            .map { [Section(model: (), items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        viewModel.event.flagTapped
            .bind {
                if Defaults.flagItems.contains($0.id) {
                    Defaults.flagItems.removeAll($0.id)
                } else {
                    Defaults.flagItems.append($0.id)
                }
            }
            .disposed(by: rx.disposeBag)
    }
}
