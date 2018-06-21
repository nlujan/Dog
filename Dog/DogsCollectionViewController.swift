//
//  DogsCollectionViewController.swift
//  Dog
//
//  Created by Naim Lujan on 6/19/18.
//  Copyright © 2018 Naim Lujan. All rights reserved.
//

import UIKit
import RxSwift
import SDWebImage

class DogsCollectionViewController: UICollectionViewController {

    let viewModel = DogsViewModel()
    let disposeBag = DisposeBag()
    let pickerView = UIPickerView()

    var layoutStyle: LayoutStyle = .list

    lazy var listLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.5
        layout.minimumLineSpacing = 1.0
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.width/1.75)
        return layout
    }()

    lazy var gridLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.5
        layout.minimumLineSpacing = 1.0
        layout.itemSize = CGSize(width: (view.bounds.width - 2)/3, height: view.bounds.width/3)
        return layout
    }()

    enum LayoutStyle {
        case list
        case grid
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewModel()

        viewModel.loadBreeds()
    }

    func setupViews() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .white
        collectionView?.setCollectionViewLayout(listLayout, animated: false)
        navigationItem.titleView = pickerView
        collectionView?.dataSource = nil
        pickerView.subviews[1].isHidden = true
        pickerView.subviews[2].isHidden = true
    }

    func bindViewModel() {
        guard let collectionView = collectionView else { return }

        viewModel.dogImages.asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { [weak self] images in
                if let collectionView = self?.collectionView, let topLength = self?.view.safeAreaInsets.top {
                    collectionView.setContentOffset(CGPoint(x: 0, y: -topLength), animated: false)
                }
            })
            .bind(to: collectionView.rx.items(cellIdentifier: "Cell", cellType: DogImageCell.self)) { row, data, cell in
                cell.imageView.sd_setImage(with: URL(string: data))
            }.disposed(by: disposeBag)

        viewModel.dogBreeds.asObservable()
            .bind(to: pickerView.rx.itemTitles) { $1 }
            .disposed(by: disposeBag)

        pickerView.rx.modelSelected(String.self)
            .map { $0.first ?? ""}
            .filter { !$0.isEmpty }
            .bind(to: viewModel.selectedBreed)
            .disposed(by: disposeBag)

        pickerView.delegate = nil
        pickerView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    @IBAction func toggleLayout(_ sender: Any) {

        if let button = sender as? UIBarButtonItem {
            switch layoutStyle {
            case .list:
                button.image = #imageLiteral(resourceName: "keypad")
                collectionView?.setCollectionViewLayout(gridLayout, animated: true)
                layoutStyle = .grid
            case .grid:
                button.image = #imageLiteral(resourceName: "list")
                collectionView?.setCollectionViewLayout(listLayout, animated: true)
                layoutStyle = .list
            }
        }
    }
}

extension DogsCollectionViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Verdana-Bold", size: 14)
        label.text = viewModel.dogBreeds.value[row].capitalizedFirstLetter()
        return label
    }
}
