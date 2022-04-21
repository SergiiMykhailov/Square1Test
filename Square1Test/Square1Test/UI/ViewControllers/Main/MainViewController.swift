//
//  ViewController.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import MapKit
import UIKit

class MainViewController: UIViewController {

    // MARK: - Public methods and properties

    public func configure(withViewModel viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel

        viewModel.onCitiesCountLoaded = { citiesCount in
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }

    // MARK: - Overridden methods

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(
            UINib(nibName: Constants.cellXibName, bundle: nil),
            forCellWithReuseIdentifier: Constants.cellIdentifier
        )
    }

    // MARK: - Outlets

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var mapView: MKMapView!

    // MARK: - Actions

    @IBAction private func onSelectedSegmentItemChanged(sender: UISegmentedControl) {
        var collectionViewOpacity: CGFloat = 1.0

        if sender.selectedSegmentIndex == Constants.mapSegmentIndex {
            collectionViewOpacity = 0.0
        }

        UIView.animate(withDuration: Constants.fadeAnimationDuration) { [weak self] in
            self?.collectionView.alpha = collectionViewOpacity
        }
    }

    // MARK: - Internal fields

    private var viewModel: MainViewModelProtocol?
    private var cellToItemIndexMap = [MainViewControllerCell: Int]()

    private enum Constants {
        static let mapSegmentIndex = 1
        static let fadeAnimationDuration: TimeInterval = 0.25

        static let cellXibName = "MainViewControllerCell"
        static let cellIdentifier = "CityCell"

        static let cellHeight: CGFloat = 64
    }

}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.totalCitiesCount != nil ? viewModel!.totalCitiesCount! : 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.cellIdentifier,
            for: indexPath
        ) as! MainViewControllerCell

        cellToItemIndexMap[cell] = indexPath.item

        viewModel?.loadCityInfo(
            atIndex: indexPath.item,
            completion: { loadedCityInfo in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self,
                          let loadedCityInfo = loadedCityInfo else {
                        return
                    }

                    if (self.cellToItemIndexMap[cell] == indexPath.item) {
                        // The cell is still attached to the same item index
                        let cellModel = MainViewControllerCell.Model(withTitle: loadedCityInfo.name)
                        cell.configure(withModel: cellModel)
                    }
                }
            }
        )

        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: collectionView.frame.width,
            height: Constants.cellHeight
        )
    }
}
