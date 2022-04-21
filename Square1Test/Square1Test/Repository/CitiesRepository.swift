//
//  CitiesRepository.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import Foundation

public typealias OnCitiesBatchLoadedCallback = ([CityInfo], Int, Bool) -> Void

public protocol CitiesRepositoryProtocol {

    func loadNext(from startIndex: Int, completion: @escaping OnCitiesBatchLoadedCallback)

}

public class DefaultCitiesRepository: CitiesRepositoryProtocol {

    // MARK: - Public methods and properties

    public init(withSearchString searchString: String) {
        self.searchString = searchString
    }

    public func loadNext(
        from startIndex: Int,
        completion: @escaping OnCitiesBatchLoadedCallback
    ) {
        
    }

    // MARK: - Internal fields

    private let searchString: String

}
