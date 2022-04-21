//
//  MainViewModel.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import Foundation

public protocol MainViewModelProtocol: AnyObject {

    var searchText: String { get set }
    var onCitiesCountUpdated: OnCitiesCountLoadedCallback? { get set }
    var totalCitiesCount: Int? { get }

    func loadCityInfo(atIndex index: Int, completion: @escaping OnCityLoadedCallback)

}

public protocol CitiesRepositoryFactoryProtocol {

    func makeRepository(withSearchText searchText: String) -> CitiesRepositoryProtocol

}

public class MainViewModel: MainViewModelProtocol {

    // MARK: - Public methods and properties

    public var searchText: String = "" {
        didSet {
            scheduleReload()
        }
    }
    public var onCitiesCountUpdated: OnCitiesCountLoadedCallback?
    public var totalCitiesCount: Int?

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
        currentCitiesRepository?.loadCityInfo(
            atIndex: index,
            completion: { loadedCityInfo in
                completion(loadedCityInfo)
            }
        )
    }

    // MARK: - Internal methods

    private func scheduleReload() {
        reloadDelayTimer?.invalidate()

        reloadDelayTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.typingDelay,
            repeats: false,
            block: { [weak self] _ in
                self?.reload()
            })
    }

    private func reload() {
        currentCitiesRepository = repositoriesFactory.makeRepository(withSearchText: searchText)
        
        currentCitiesRepository?.loadTotalItemsCount(completion: { [weak self] itemsCount in
            self?.totalCitiesCount = itemsCount
            self?.onCitiesCountUpdated?(itemsCount)
        })
    }

    // MARK: - Internal fields

    private let repositoriesFactory: CitiesRepositoryFactoryProtocol
    private var currentCitiesRepository: CitiesRepositoryProtocol?
    private var reloadDelayTimer: Timer?

    private enum Constants {
        static let typingDelay: TimeInterval = 0.5
    }

}
