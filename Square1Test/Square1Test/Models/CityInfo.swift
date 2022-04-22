//
//  CityInfo.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import Foundation

public class CityInfo {

    // MARK: - Public methods and properties

    public static func arrayFromJSON(json: [Any]) -> [CityInfo] {
        var result = [CityInfo]()

        for jsonEntry in json {
            if let itemJson = jsonEntry as? [AnyHashable: Any],
               let itemToInsert = fromJSON(json: itemJson) {
                result.append(itemToInsert)
            }
        }

        return result
    }

    public static func fromJSON(json: [AnyHashable: Any]) -> CityInfo? {
        guard let id = json[JSONKeys.id] as? Int,
              let name = json[JSONKeys.name] as? String,
              let latitude = json[JSONKeys.latitude] as? Double,
              let longitude = json[JSONKeys.longitude] as? Double else {
                  return nil
              }

        return CityInfo(
            withId: "\(id)",
            name: name,
            latitude: Float(latitude),
            longitude: Float(longitude)
        )
    }

    public init(
        withId id: String,
        name: String,
        latitude: Float,
        longitude: Float
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }

    let id: String
    let name: String
    let latitude: Float
    let longitude: Float

    // Internal fields

    private enum JSONKeys {
        static let id = "id"
        static let name = "name"
        static let latitude = "lat"
        static let longitude = "lng"
    }

}
