//
//  API.swift
//  Dog
//
//  Created by Naim Lujan on 6/19/18.
//  Copyright © 2018 Naim Lujan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct DogService {

    static func allBreeds() -> Observable<[String]> {
        guard let url = URL(string: Route.allBreeds.fullPath) else { return Observable.from([]) }

        return URLSession.shared.rx.json(url: url)
            .catchErrorJustReturn([])
            .map { json -> [String] in
                if let json = json as? [String: Any], let dogDict = json["message"] as? [String: Any] {
                    return dogDict.keys.sorted()
                } else {
                    return []
                }
        }
    }

    static func images(for breed: String) -> Observable<[String]> {
        guard let url = URL(string: Route.breedImages(breed).fullPath) else { return Observable.from([]) }

        return URLSession.shared.rx.json(url: url)
            .catchErrorJustReturn([])
            .map { json -> [String] in
                if let json = json as? [String: Any], let images = json["message"] as? [String] {
                    return images
                } else {
                    return []
                }
            }
    }
}

enum Route {
    case allBreeds
    case breedImages(String)

    private var base: String {
        return "https://dog.ceo/api/"
    }

    private var path: String {
        switch self {
        case .allBreeds: return "breeds/list/all"
        case .breedImages(let breed): return "breed/\(breed)/images"
        }
    }

    var fullPath: String {
        return base + path
    }
}


