//
//  PagesNetworkService.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import Foundation

final class PagesNetworkService {
    private let uploadPhotoPath:String = "/api/v2/photo"
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
    
    func uploadPhoto(
        pageContent: PageContent,
        fileName:String,
        photo: Data,
        fileType:MultipartRequest.FileType = .jpeg,
        complition: @escaping (Error?) -> ()) {
            var photoUploadComponents = baseURLComponents
            photoUploadComponents.path = uploadPhotoPath
            
            var request = MultipartRequest(url: photoUploadComponents.url!)
            request.addFormField(
                fieldName: "name",
                value: pageContent.name)
            request.addFile(
                fieldName: "photo",
                fileName: fileName,
                file: photo,
                fileType: fileType)
            request.addFormField(
                fieldName: "typeId",
                value: String(pageContent.id))
            
            request.sendRequest(complition: complition)
        }
}
