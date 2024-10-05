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
