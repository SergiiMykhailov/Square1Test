//
//  CitiesLocalStorage.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 22.04.2022.
//

import CoreData
import Foundation
import UIKit

public typealias LocalStorageCityStoreCallback = (Error?) -> Void
public typealias LocalStorageCitiesLoadCallback = ([CityInfo], Error?) -> Void

public protocol CitiesLocalStorageProtocol {

    func loadCities(
        whereTitleContains searchString: String,
        completion: @escaping LocalStorageCitiesLoadCallback
    )

    func save(
        city: CityInfo,
        completion: @escaping LocalStorageCityStoreCallback
    )

}

public class CoreDataCitiesLocalStorage {

    // MARK: - Internal fields

    private enum DatabaseConstants {
        static let cityEntityName = "LSCityInfo"

        static let idField = "id"
        static let nameField = "name"
        static let latitudeField = "latitude"
        static let longitudeField = "longitude"
    }

}

extension CoreDataCitiesLocalStorage: CitiesLocalStorageProtocol {
    public func loadCities(
        whereTitleContains searchString: String,
        completion: @escaping LocalStorageCitiesLoadCallback
    ) {
        DispatchQueue.main.async {
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                return
            }

            let fetchRequest = NSFetchRequest<NSManagedObject>(
                entityName: DatabaseConstants.cityEntityName
            )

            do {
                let requestedCities = try context.fetch(fetchRequest)
                let result = type(of: self).cityInfoList(fromManagedObjects: requestedCities)

                completion(result, nil)
            } catch let error as NSError {
                completion([], error)
            }
        }
    }

    public func save(
        city: CityInfo,
        completion: @escaping LocalStorageCityStoreCallback
    ) {
        DispatchQueue.main.async {
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                return
            }

            let entity =
                NSEntityDescription.entity(
                    forEntityName: DatabaseConstants.cityEntityName,
                    in: context
                )!

            let person = NSManagedObject(entity: entity, insertInto: context)

            person.setValue(city.id, forKeyPath: DatabaseConstants.idField)
            person.setValue(city.name, forKeyPath: DatabaseConstants.nameField)
            person.setValue(city.latitude, forKeyPath: DatabaseConstants.latitudeField)
            person.setValue(city.longitude, forKeyPath: DatabaseConstants.longitudeField)

            do {
                try context.save()
                completion(nil)
            } catch let error as NSError {
                completion(error)
            }
        }
    }

    private static func cityInfoList(
        fromManagedObjects managedObjects: [NSManagedObject]
    ) -> [CityInfo] {
        var result = [CityInfo]()

        for managedObject in managedObjects {
            if let id = managedObject.value(forKey: DatabaseConstants.idField) as? String,
               let name = managedObject.value(forKey: DatabaseConstants.nameField) as? String,
               let latitude = managedObject.value(forKey: DatabaseConstants.latitudeField) as? Float,
               let longitude = managedObject.value(forKey: DatabaseConstants.longitudeField) as? Float {
                let cityInfo = CityInfo(
                    withId: id,
                    name: name,
                    latitude: latitude,
                    longitude: longitude
                )

                result.append(cityInfo)
            }
        }

        return result
    }
}
