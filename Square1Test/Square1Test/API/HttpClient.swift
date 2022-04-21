//
//  HttpClient.swift
//  Square1Test
//
//  Created by Serg Mykhailov on 21.04.2022.
//

import Foundation

public class HttpClient {

    // MARK: - Public methods and properties

    public static func loadCities(
        forPage pageIndex: Int,
        withSearchString searchString: String,
        completion: @escaping OnCitiesBatchLoadedCallback
    ) {
        var url = Constants.baseUrl + Constants.endpointCity + "?include=country&page=\(pageIndex)"
        if !searchString.isEmpty {
            url += "filter[0][name][contains]=\(searchString)"
        }

        let task = URLSession.shared.dataTask(
            with: URL(string: url)!,
            completionHandler: { (data, response, error) in
                if let error = error {
                    print("Error with fetching films: \(error)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                    return
                }

                if let data = data,
                   let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any],
                   let itemsJSON = itemsArray(fromResponseJSON: responseJSON),
                   let totalItemsCount = totalItemsCount(fromResponseJSON: responseJSON) {
                        let loadedCities = CityInfo.arrayFromJSON(json: itemsJSON)

                        return completion(loadedCities, totalItemsCount)
                   }
            })
        
        task.resume()
    }

    // MARK: - Internal methods

    private static func itemsArray(
        fromResponseJSON responseJSON: [AnyHashable: Any]
    ) -> [Any]? {
        guard let dataJSON = responseJSON[JSONKeys.data] as? [AnyHashable: Any],
              let itemsJSON = dataJSON[JSONKeys.items] as? [Any] else {
                  return nil
              }

        return itemsJSON
    }

    private static func totalItemsCount(
        fromResponseJSON responseJSON: [AnyHashable: Any]
    ) -> Int? {
        guard let dataJSON = responseJSON[JSONKeys.data] as? [AnyHashable: Any],
              let paginationJSON = dataJSON[JSONKeys.pagination] as? [AnyHashable: Any],
              let totalItemsCount = paginationJSON[JSONKeys.total] as? Int else {
                  return nil
              }

        return totalItemsCount
    }

    // MARK: - Internal fields

    private enum Constants {
        static let baseUrl = "http://connect-demo.mobile1.io/square1/connect/v1/"
        static let endpointCity = "city"
    }

    private enum JSONKeys {
        static let data = "data"
        static let items = "items"
        static let pagination = "pagination"
        static let total = "total"
    }

}
