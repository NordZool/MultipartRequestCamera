//
//  PhotoNetworkService.swift
//  MultipartRequestCamera
//
//  Created by nikita on 5.10.24.
//

import Foundation

class PhotoNetworkService {
    private let uploadPhotoPath:String = "/api/v2/photo"
    private var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "junior.balinasoft.com"
        return components
    }
    
    func uploadPhoto(
        name: String,
        typeId: Int,
        fileName:String,
        photo: Data,
        fileType:MultipartRequest.FileType = .jpeg,
        complition: @escaping (Result<Void,MultipartRequestError>) -> ()) {
            var photoUploadComponents = baseURLComponents
            photoUploadComponents.path = uploadPhotoPath
            
            var request = MultipartRequest(url: photoUploadComponents.url!)
            request.addFormField(
                fieldName: "name",
                value: name)
            request.addFile(
                fieldName: "photo",
                fileName: fileName,
                file: photo,
                fileType: fileType)
            request.addFormField(
                fieldName: "typeId",
                value: String(typeId))
            
            request.sendRequest(complition: complition)
        }
}
