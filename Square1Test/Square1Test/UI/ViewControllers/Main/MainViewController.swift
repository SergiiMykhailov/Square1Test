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

        viewModel.onCitiesCountUpdated = { citiesCount in
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
                self?.reloadMap()
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

    // MARK: - Internal methods

    private func reloadMap() {
        guard let totalItemsCount = viewModel?.totalCitiesCount else {
            return
        }

        mapView.removeAnnotations(mapView.annotations)

        for itemIndex in 0..<totalItemsCount {
            viewModel?.loadCityInfo(
                atIndex: itemIndex,
                completion: { [weak self] loadedCity in
                    guard let self = self, let loadedCity = loadedCity else {
                        return
                    }

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(loadedCity.latitude),
                        longitude: CLLocationDegrees(loadedCity.longitude)
                    )
                    annotation.title = loadedCity.name

                    self.mapView.addAnnotation(annotation)
                }
            )
        }
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

extension MainViewController: UISearchBarDelegate {
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        viewModel?.searchText = searchText
    }
}
