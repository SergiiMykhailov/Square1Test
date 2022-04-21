//
//  MainViewModel.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import Foundation

public typealias OnCitiesCountLoadedCallback = (Int) -> Void
public typealias OnCityLoadedCallback = (CityInfo?) -> Void

public protocol MainViewModelProtocol: AnyObject {

    var searchText: String { get set }
    var onCitiesLoaded: OnCitiesCountLoadedCallback? { get set }
    var totalCitiesCount: Int { get }

    func loadCityInfo(atIndex index: Int, complection: @escaping OnCityLoadedCallback)

}

public class MainViewModel: MainViewModelProtocol {

    // MARK: - Public methods and properties

    public var searchText: String = ""
    public var onCitiesLoaded: OnCitiesCountLoadedCallback?
    public var totalCitiesCount: Int = 0

    public func loadCityInfo(
        atIndex index: Int,
        complection: @escaping OnCityLoadedCallback
    ) {
        
    }

}
