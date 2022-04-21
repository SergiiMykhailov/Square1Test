//
//  ViewController.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import MapKit
import UIKit

class MainViewController: UIViewController,
                          UICollectionViewDataSource,
                          UICollectionViewDelegate {

    // MARK: - Public methods and properties

    public func configure(withViewModel viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel

        viewModel.onCitiesLoaded = { [weak self] citiesCount in
            self?.collectionView.reloadData()
        }
    }

    // MARK: - Overridden methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - UICollectionViewDataSource implementation

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel != nil ? viewModel!.totalCitiesCount : 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return UICollectionViewCell()
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

    private enum Constants {
        static let mapSegmentIndex = 1
        static let fadeAnimationDuration: TimeInterval = 0.25
    }

}

