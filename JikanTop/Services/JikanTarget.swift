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

enum ItemType: String, Decodable {
    case anime
    case manga
    case people
    case characters
}

// MARK: - ItemSubtype

protocol ItemSubtype {
    var rawValue: String { get }
}

// MARK: - AnimSubtype

enum AnimSubtype: String, ItemSubtype {
    case airing
    case upcoming
    case tv
    case movie
    case ova
    case special
    case bypopularity
    case favorite
}

// MARK: - MangaSubtype

enum MangaSubtype: String, ItemSubtype {
    case manga
    case novels
    case oneshots
    case doujin
    case manhwa
    case manhua
    case bypopularity
    case favorite
}
