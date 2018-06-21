//
//  DogsViewModel.swift
//  Dog
//
//  Created by Naim Lujan on 6/19/18.
//  Copyright © 2018 Naim Lujan. All rights reserved.
//

import Foundation
import RxSwift

struct DogsViewModel {

    let dogBreeds = Variable<[String]>([])
    let dogImages = Variable<[String]>([])
    let selectedBreed = PublishSubject<String>()
    let disposeBag = DisposeBag()

    init() {

        dogBreeds.asObservable()
            .map { $0.first ?? "" }
            .filter { !$0.isEmpty }
            .bind(to: selectedBreed)
            .disposed(by: disposeBag)

        selectedBreed.asObserver()
            .flatMap { DogService.images(for: $0) }
            .bind(to: dogImages)
            .disposed(by: disposeBag)
    }

    func loadBreeds() {

        DogService
            .allBreeds()
            .filter { !$0.isEmpty }
            .bind(to: dogBreeds)
            .disposed(by: disposeBag)
    }
}
