//
//  MainViewModel.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import Foundation

public protocol MainViewModelProtocol: AnyObject {

    var searchText: String { get set }
    var onCitiesCountLoaded: OnCitiesCountLoadedCallback? { get set }
    var totalCitiesCount: Int { get }

    func loadCityInfo(atIndex index: Int, completion: @escaping OnCityLoadedCallback)

}

public protocol CitiesRepositoryFactoryProtocol {

    func makeRepository(withSearchText searchText: String) -> CitiesRepositoryProtocol

}

public class MainViewModel: MainViewModelProtocol {

    // MARK: - Public methods and properties

    public var searchText: String = "" {
        didSet {
            reload()
        }
    }
    public var onCitiesCountLoaded: OnCitiesCountLoadedCallback?
    public var totalCitiesCount: Int = 0

    public init(
        withRepositoriesFactory repositoriesFactory: CitiesRepositoryFactoryProtocol
    ) {
        self.repositoriesFactory = repositoriesFactory

        reload()
    }

    public func loadCityInfo(
        atIndex index: Int,
        completion: @escaping OnCityLoadedCallback
    ) {
        if index >= totalCitiesCount {
            return completion(nil)
        }

        if index < loadedCities.count {
            return completion(loadedCities[index])
        }
        else {
            // We know that there is a city for the specified
            // index but it has not been loaded yet
            pendingCityLoadCallbacks[index] = completion
        }
    }

    // MARK: - Internal methods

    private func reload() {
        currentCitiesRepository = repositoriesFactory.makeRepository(withSearchText: searchText)
        loadedCities.removeAll()
        lastLoadedItemIndex = -1
        pendingCityLoadCallbacks.removeAll()
        totalCitiesCount = 0

        loadNextCitiesBatch()
    }

    private func loadNextCitiesBatch() {
        currentCitiesRepository?.loadNext(
            from: lastLoadedItemIndex + 1,
            completion: { [weak self] (loadedCitiesBatch, totalCount, isLoadingCompleted) in
                self?.loadedCities.append(contentsOf: loadedCitiesBatch)

                if self?.totalCitiesCount == 0 {
                    self?.totalCitiesCount = totalCount
                    self?.onCitiesCountLoaded?(totalCount)
                }

                self?.processPendingLoadingItems()

                if !isLoadingCompleted {
                    self?.loadNextCitiesBatch()
                }
            }
        )
    }

    private func processPendingLoadingItems() {
        var handledPendingItems = [Int]()

        pendingCityLoadCallbacks.forEach { (key: Int, value: OnCityLoadedCallback) in
            if key < totalCitiesCount {
                value(loadedCities[key])
                handledPendingItems.append(key)
            }
        }

        for handledItemIndex in handledPendingItems {
            pendingCityLoadCallbacks.removeValue(forKey: handledItemIndex)
        }
    }

    // MARK: - Internal fields

    private let repositoriesFactory: CitiesRepositoryFactoryProtocol
    private var currentCitiesRepository: CitiesRepositoryProtocol?
    private var loadedCities = [CityInfo]()
    private var lastLoadedItemIndex = -1
    private var pendingCityLoadCallbacks = [Int : OnCityLoadedCallback]()

    private enum Constants {
        static let itemsCountPerBatch = 20
    }

}
