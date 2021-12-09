//
//  TopItemCell.swift
//  JikanTop
//
//  Created by Eric Hsu on 2021/12/10.
//

import Kingfisher
import RxSwift
import UIKit

// MARK: - TopItemCell

final class TopItemCell: UITableViewCell {
    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    lazy var flagButton = UIButton().then {
        $0.imageForNormal = UIImage(systemName: "flag")
    }

    var bag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }

    func setup(with item: TopItem) {
        thumbnail.kf.setImage(with: item.imageUrl)
        titleLabel.text = item.title
        rankLabel.text = "No. \(item.rank)"
        dateLabel.text = [item.startDate, item.endDate]
            .compactMap { $0?.dateString(ofStyle: .medium) }
            .joined(separator: " - ")
        typeLabel.text = item.type
    }

    // MARK: Private

    private lazy var thumbnail = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    private lazy var titleLabel = UILabel(text: "", style: .title3).then {
        $0.numberOfLines = 0
    }

    private lazy var rankLabel = UILabel()
    private lazy var dateLabel = UILabel(text: "", style: .caption1)
    private lazy var typeLabel = UILabel(text: "", style: .caption2)

    private func setupViews() {
        let labelStack = UIStackView(
            arrangedSubviews: [titleLabel, rankLabel, dateLabel, typeLabel],
            axis: .vertical,
            spacing: 4
        )
        let contentStack = UIStackView(
            arrangedSubviews: [thumbnail, labelStack, UIView(), flagButton],
            axis: .horizontal,
            spacing: 10,
            alignment: .center
        )
        contentView.addSubview(contentStack)
        contentStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
        thumbnail.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.25)
            $0.height.equalTo(150)
        }
    }
}

#if DEBUG
import SwiftUI
struct TopItemCellPreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            TopItemCellPreview().previewLayout(.fixed(width: 375, height: 150))
        }
    }
}

struct TopItemCellPreview: UIViewRepresentable {
    let dummyItem: TopItem = try! JSONDecoder().decode(TopItem.self, from: #"""
    {
        "mal_id": 48583,
        "rank": 1,
        "title": "Shingeki no Kyojin: The Final Season Part 2",
        "url": "https://myanimelist.net/anime/48583/Shingeki_no_Kyojin__The_Final_Season_Part_2",
        "image_url": "https://cdn.myanimelist.net/images/anime/1988/119437.jpg?s=aad31fb4d3d6d893c32a52ae666698ac",
        "type": "TV",
        "episodes": null,
        "start_date": "Jan 2022",
        "end_date": null,
        "members": 384015,
        "score": 0
    }
    """#.data(using: .utf8)!)

    func makeUIView(context: Context) -> TopItemCell {
        TopItemCell()
    }

    func updateUIView(_ cell: TopItemCell, context: Context) {
        cell.setup(with: dummyItem)
    }
}

#endif
