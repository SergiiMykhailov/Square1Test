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

    public init(
        withSearchString searchString: String,
        localStorage: CitiesLocalStorageProtocol? = nil
    ) {
        self.searchString = searchString
        self.localStorage = localStorage

        loadFromLocalStorage { [weak self] in
            self?.loadRemainingBatches()
        }
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
                for loadedCity in loadedCitiesBatch {
                    self.loadedCities.removeAll(where: { $0.id == loadedCity.id })
                    self.loadedCities.append(loadedCity)
                }

                if self.totalItemsCount == nil {
                    self.totalItemsCount = totalItems
                }

                self.saveCitiesToLocalStorage(loadedCitiesBatch)
                self.processPendingCallbacks()

                let isLoadingCompleted = self.loadedCities.count == totalItems
                if !isLoadingCompleted && !loadedCitiesBatch.isEmpty {
                    self.loadRemainingBatches()
                }

                if loadedCitiesBatch.isEmpty {
                    // There may be a case when total items count which was
                    // retrieved during the 1st page loading is wrong
                    // and at some point we start retrieving empty batches.
                    // In this case we may detect that there is actually no more data.
                    self.totalItemsCount = self.loadedCities.count
                }
            }
    }

    private func loadFromLocalStorage(completion: VoidCallback?) {
        guard let localStorage = localStorage else {
            completion?()
            return
        }

        localStorage.loadCities(whereTitleContains: searchString) { [weak self] cities, error in
            if let error = error {
                print("Failed to load cities from local storage.\nError: \(error.localizedDescription)")
            }
            else {
                self?.loadedCities = cities
            }

            completion?()
        }
    }

    private func saveCitiesToLocalStorage(_ cities: [CityInfo]) {
        guard let localStorage = localStorage else {
            return
        }

        for city in cities {
            localStorage.save(city: city, completion: { error in
                if let error = error {
                    print("Failed to store city localy. \nError: \(error.localizedDescription)")
                }
            })
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
    private let localStorage: CitiesLocalStorageProtocol?

    private var totalItemsCount: Int?
    private var totalItemsCountPendingCallbacks = [OnCitiesCountLoadedCallback]()
    private var loadedCities = [CityInfo]()
    private var lastLoadedPageIndex = 0
    private var pendingCityLoadCallbacks = [Int: OnCityLoadedCallback]()

}
