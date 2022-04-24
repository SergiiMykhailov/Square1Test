//
//  Environment.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import Foundation

class Environment {

    public static let repositoriesFactory = DefaultCitiesRepositoriesFactory()

}

class DefaultCitiesRepositoriesFactory: CitiesRepositoryFactoryProtocol {
    func makeRepository(withSearchText searchText: String) -> CitiesRepositoryProtocol {
        DefaultCitiesRepository(
            withSearchString: searchText,
            localStorage: CoreDataCitiesLocalStorage.shared
        )
    }
}
