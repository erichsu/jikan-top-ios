//
//  FlagItemsViewController.swift
//  JikanTop
//
//  Created by Eric Hsu on 2021/12/10.
//

import RxDataSources
import SwiftyUserDefaults
import UIKit

final class FlagItemsViewController: UIViewController {
    // MARK: Internal

    typealias Section = SectionModel<Void, TopItem>

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = doneBarButton
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        Defaults.observe(\.flagItems)
            .compactMap(\.newValue)
            .do(onNext: { [weak self] in self?.emptyLabel.isHidden = !$0.isEmpty })
            .map { [Section(model: (), items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.modelDeleted(Section.Item.self)
            .bind { item in
                Defaults.flagItems.removeAll(where: { $0.id == item.id })
            }
            .disposed(by: rx.disposeBag)

        doneBarButton.rx.tap
            .bind(with: self) { `self`, _ in self.dismiss(animated: true) }
            .disposed(by: rx.disposeBag)
    }

    // MARK: Private

    private lazy var doneBarButton = UIBarButtonItem(systemItem: .done, primaryAction: nil, menu: nil)

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Section>(
        configureCell: { _, tableView, index, item in
            let cell = tableView.dequeueReusableCell(withClass: TopItemCell.self, for: index)
            cell.setup(with: item, isFlag: true)
            return cell
        }
    )

    private lazy var emptyLabel = UILabel(text: "No flag items").then {
        $0.textAlignment = .center
    }

    private lazy var tableView = UITableView().then {
        $0.register(cellWithClass: TopItemCell.self)
        $0.backgroundView = emptyLabel
    }
}
