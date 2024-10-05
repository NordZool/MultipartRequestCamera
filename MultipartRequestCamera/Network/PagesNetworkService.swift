//
//  PagesNetworkService.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import Foundation

final class PagesNetworkService {
    private let getPageTypePath: String = "/api/v2/photo/type"
    private var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "junior.balinasoft.com"
        return components
    }
    
    func getPageType(
        with pageValue: String,
        complition: @escaping (Result<PageType,Error>) -> ()) {
            var getPageTypeComponents = baseURLComponents
            getPageTypeComponents.path = getPageTypePath
            getPageTypeComponents.queryItems = [.init(
                name: "page",
                value: pageValue)]
            
            var request = URLRequest(url: getPageTypeComponents.url!)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data,
                   let resultPageType = try? JSONDecoder().decode(PageType.self, from: data) {
                    complition(.success(resultPageType))
                } else if let error = error {
                    complition(.failure(error))
                }
            }
            task.resume()
        }
    
    func downloadImage(from url: URL, complition: @escaping (Result<Data,Error>) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let data = data {
                complition(.success(data))
            } else if let error = error {
                complition(.failure(error))
            }
        }
        task.resume()
    }
}
