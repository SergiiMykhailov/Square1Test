//
//  CitiesRepository.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import Foundation

public protocol CitiesRepositoryProtocol {

    func loadTotalItemsCount(completion: @escaping OnCitiesCountLoadedCallback)
    func loadCityInfo(atIndex index: Int, completion: @escaping OnCityLoadedCallback)

}

public class DefaultCitiesRepository: CitiesRepositoryProtocol {

    // MARK: - Public methods and properties

    public init(withSearchString searchString: String) {
        self.searchString = searchString

        loadRemainingBatches()
    }

    public func loadTotalItemsCount(completion: @escaping OnCitiesCountLoadedCallback) {
        if let totalItemsCount = totalItemsCount {
            return completion(totalItemsCount)
        }

        totalItemsCountPendingCallbacks.append(completion)
    }

    public func loadCityInfo(atIndex index: Int, completion: @escaping OnCityLoadedCallback) {
        if index < loadedCities.count {
            return completion(loadedCities[index])
        }

        pendingCityLoadCallbacks[index] = completion
    }

    // MARK: - Internal methods

    private func loadRemainingBatches() {
        HttpClient.loadCities(
            forPage: lastLoadedPageIndex + 1,
            withSearchString: searchString) { [weak self] loadedCitiesBatch, totalItems in
                guard let self = self else {
                    return
                }

                self.lastLoadedPageIndex += 1
                self.loadedCities.append(contentsOf: loadedCitiesBatch)

                if self.totalItemsCount == nil {
                    self.totalItemsCount = totalItems
                }

                self.processPendingCallbacks()

                let isLoadingCompleted = self.loadedCities.count == totalItems
                if !isLoadingCompleted {
                    self.loadRemainingBatches()
                }
            }
    }

    private func processPendingCallbacks() {
        if let totalItemsCount = totalItemsCount {
            for callback in totalItemsCountPendingCallbacks {
                callback(totalItemsCount)
            }

            totalItemsCountPendingCallbacks.removeAll()
        }

        var handledPendingItems = [Int]()

        pendingCityLoadCallbacks.forEach { (key: Int, value: OnCityLoadedCallback) in
            if key < loadedCities.count {
                value(loadedCities[key])
                handledPendingItems.append(key)
            }
        }

        for handledItemIndex in handledPendingItems {
            pendingCityLoadCallbacks.removeValue(forKey: handledItemIndex)
        }
    }

    // MARK: - Internal fields

    private let searchString: String
    private var totalItemsCount: Int?
    private var totalItemsCountPendingCallbacks = [OnCitiesCountLoadedCallback]()
    private var loadedCities = [CityInfo]()
    private var lastLoadedPageIndex = -1
    private var pendingCityLoadCallbacks = [Int: OnCityLoadedCallback]()

}
