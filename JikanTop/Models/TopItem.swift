//
//  TopItem.swift
//  JikanTop
//
//  Created by Eric Hsu on 2021/12/10.
//

import BackedCodable
import Foundation
import Codextended

// MARK: - TopItem

/// Data model of Top items on MyAnimeList
///
/// Please refer to sample as below
/// ```json
/// {
///        "mal_id": 48583,
///        "rank": 1,
///        "title": "Shingeki no Kyojin: The Final Season Part 2",
///        "url": "https://myanimelist.net/anime/48583/Shingeki_no_Kyojin__The_Final_Season_Part_2",
///        "image_url": "https://cdn.myanimelist.net/images/anime/1988/119437.jpg?s=aad31fb4d3d6d893c32a52ae666698ac",
///        "type": "TV",
///        "episodes": null,
///        "start_date": "Jan 2022",
///        "end_date": null,
///        "members": 384015,
///        "score": 0
/// }
/// ```
struct TopItem: BackedDecodable {
    // MARK: Lifecycle

    init(_: DeferredDecoder) {}

    // MARK: Internal

    @Backed("mal_id")
    var id: Int

    @Backed()
    var rank: Int

    @Backed()
    var title: String

    @Backed()
    var url: URL?

    @Backed("image_url")
    var imageUrl: URL?

    @Backed()
    var type: String

    @Backed()
    var episodes: String?

    @Backed("start_date", strategy: .formatted(.backend))
    var startDate: Date?

    @Backed("end_date", strategy: .formatted(.backend))
    var endDate: Date?

    @Backed()
    var members: Int

    @Backed()
    var score: Double
}

extension TopItem: Encodable {
    func encode(to encoder: Encoder) throws {
        try encoder.encode(id, for: "id")
        try encoder.encode(rank, for: "rank")
        try encoder.encode(title, for: "title")
        try encoder.encode(url, for: "url")
        try encoder.encode(imageUrl, for: "image_url")
        try encoder.encode(type, for: "type")
        try encoder.encode(episodes, for: "episodes")
        try encoder.encode(startDate, for: "start_date")
        try encoder.encode(endDate, for: "end_date")
        try encoder.encode(members, for: "members")
        try encoder.encode(score, for: "score")
    }
}

import Then

extension DateFormatter {
    /// Custom date formatter for Jikan API with pattern "MMM yyyy"
    static let backend = DateFormatter().then {
        $0.dateFormat = "MMM yyyy"
    }
}
