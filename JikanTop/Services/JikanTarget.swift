//
//  JikanTarget.swift
//  JikanTop
//
//  Created by Eric Hsu on 2021/12/10.
//

import Foundation
import MoyaSugar

let API = MoyaSugarProvider<JikanTarget>()

// MARK: - JikanTarget

enum JikanTarget: SugarTargetType {
    case topItems(type: ItemType, subtype: ItemSubtype?, page: Int?)

    // MARK: Internal

    var route: Route {
        switch self {
        case .topItems(let type, let subtype, let page):
            let subpath = [type.rawValue, page?.string, subtype?.rawValue]
                .compactMap(by: \.self)
                .joined(separator: "/")
            return .get("/top/\(subpath)")
        }
    }

    var parameters: Parameters? { nil }
    var baseURL: URL { "https://api.jikan.moe/v3".url! }
    var headers: [String: String]? { nil }
}

// MARK: - ItemType

enum ItemType: String, CaseIterable {
    case anime
    case manga
    case people
    case characters
}

// MARK: - ItemSubtype

enum ItemSubtype: String {
    // Anim only
    case airing
    case upcoming
    case tv
    case movie
    case ova
    case special

    // Manga only
    case manga
    case novels
    case oneshots
    case doujin
    case manhwa
    case manhua

    // both
    case bypopularity
    case favorite

    // MARK: Internal

    static var animSubtypes: [ItemSubtype] {
        [airing, upcoming, tv, movie, ova, special, bypopularity, favorite]
    }

    static var mangaSubtypes: [ItemSubtype] {
        [manga, novels, oneshots, doujin, manhwa, manhua, bypopularity, favorite]
    }
}
