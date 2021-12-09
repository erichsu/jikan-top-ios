//
//  ViewController.swift
//  JikanTop
//
//  Created by Eric Hsu on 2021/12/10.
//

import RxDataSources
import RxSwift
import SnapKit
import UIKit
import SafariServices

// MARK: - ViewController

class ViewController: UIViewController {
    // MARK: Internal

    typealias Section = SectionModel<Void, String>

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        Observable.just([Section(model: (), items: ["1", "2"])])
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(Section.Item.self)
            .bind(with: self) { `self`, _ in
                let webView = SFSafariViewController(url: "https://google.com".url!)
                self.present(webView, animated: true)
            }
            .disposed(by: rx.disposeBag)
    }

    // MARK: Private

    private lazy var tableView = UITableView().then {
        $0.register(cellWithClass: TopItemCell.self)
    }

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Section>(
        configureCell: { _, tableView, index, _ in
            let cell = tableView.dequeueReusableCell(withClass: TopItemCell.self, for: index)
            cell.textLabel?.text = "test"
            return cell
        }
    )
}

// MARK: - TopItemCell

final class TopItemCell: UITableViewCell {}
