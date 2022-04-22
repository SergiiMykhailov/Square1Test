//
//  DataTypes.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import Foundation

public typealias VoidCallback = () -> Void
public typealias OnCitiesCountLoadedCallback = (Int) -> Void
public typealias OnCityLoadedCallback = (CityInfo?) -> Void
public typealias OnCitiesBatchLoadedCallback = ([CityInfo], Int) -> Void
