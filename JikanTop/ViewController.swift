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

    enum Constants {
        static let pageCount = 50
    }

    let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindInput()
        bindOutput()
    }

    // MARK: Private

    private lazy var flagBarButton = UIBarButtonItem(image: UIImage(systemName: "flag.fill"), style: .plain, target: nil, action: nil)

    private lazy var typeBarButton = UIBarButtonItem(title: "Type", style: .plain, target: nil, action: nil)
    private lazy var subtypeBarButton = UIBarButtonItem(title: "All Subtype", style: .plain, target: nil, action: nil)
    private lazy var pickerView = UIPickerView()

    private lazy var tableView = UITableView().then {
        $0.register(cellWithClass: TopItemCell.self)
    }

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Section>(
        configureCell: { _, tableView, index, item in
            let cell = tableView.dequeueReusableCell(withClass: TopItemCell.self, for: index)
            cell.setup(with: item, isFlag: Defaults.flagItems.contains(where: { $0.id == item.id }))
            cell.flagButton.rx.tap
                .bind(with: self) { `self`, _ in
                    self.viewModel.event.flagTapped.accept(item)
                }
                .disposed(by: cell.bag)
            return cell
        }
    )

    private func setupViews() {
        navigationItem.rightBarButtonItems = [flagBarButton, subtypeBarButton, typeBarButton]

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

        flagBarButton.rx.tap
            .bind(with: self) { `self`, _ in
                let vc = FlagItemsViewController()
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
            }
            .disposed(by: rx.disposeBag)

        typeBarButton.rx.tap
            .bind(with: self) { `self`, _ in
                let sheet = UIAlertController(title: "Type", message: nil, preferredStyle: .actionSheet)
                ItemType.allCases.forEach { type in
                    let action = UIAlertAction(title: type.rawValue.capitalized, style: .default) { _ in
                        self.viewModel.state.selectedType.accept(type)
                    }
                    sheet.addAction(action)
                }
                self.present(sheet, animated: true)
            }
            .disposed(by: rx.disposeBag)

        subtypeBarButton.rx.tap
            .bind(with: self) { `self`, _ in
                let sheet = UIAlertController(title: "Subtype", message: nil, preferredStyle: .actionSheet)
                sheet.addAction(UIAlertAction(title: "All Subtype", style: .default, handler: { _ in
                    self.viewModel.state.selectedSubType.accept(nil)
                }))
                switch self.viewModel.state.selectedType.value {
                case .anime:
                    ItemSubtype.animSubtypes.forEach { subtype in
                        let action = UIAlertAction(title: subtype.rawValue.capitalized, style: .default) { _ in
                            self.viewModel.state.selectedSubType.accept(subtype)
                        }
                        sheet.addAction(action)
                    }
                case .manga:
                    ItemSubtype.mangaSubtypes.forEach { subtype in
                        let action = UIAlertAction(title: subtype.rawValue.capitalized, style: .default) { _ in
                            self.viewModel.state.selectedSubType.accept(subtype)
                        }
                        sheet.addAction(action)
                    }
                default: break
                }
                self.present(sheet, animated: true)
            }
            .disposed(by: rx.disposeBag)

        tableView.rx.willDisplayCell
            .withLatestFrom(viewModel.state.lastPage) { cell, page in (cell.indexPath.row, page) }
            .filter { $0 == (Constants.pageCount * $1)  - 1 }
            .map { _ in }
            .bind(to: viewModel.event.didScrollBottom)
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
            .bind { item in
                if Defaults.flagItems.contains(where: { $0.id == item.id }) {
                    Defaults.flagItems.removeAll(where: { $0.id == item.id })
                } else {
                    Defaults.flagItems.append(item)
                }
            }
            .disposed(by: rx.disposeBag)

        viewModel.state.selectedType
            .map(\.rawValue.capitalized)
            .bind(to: typeBarButton.rx.title)
            .disposed(by: rx.disposeBag)

        viewModel.state.selectedType
            .map { [.anime, .manga].contains($0) }
            .bind(to: subtypeBarButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        viewModel.state.selectedSubType
            .map { $0?.rawValue.capitalized ?? "All Subtype" }
            .bind(to: subtypeBarButton.rx.title)
            .disposed(by: rx.disposeBag)
    }
}
