//
//  PagesNetworkService.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import Foundation

final class PagesNetworkService {
    private let uploadPhotoPath:String = "/api/v2/photo"
    private let getPhotoTypePath: String = "/api/v2/photo/type"
    private var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "junior.balinasoft.com"
        return components
    }
    
    func uploadPhoto(
        fileName:String,
        photo: Data,
        fileType:MultipartRequest.FileType = .jpeg) {
            var photoUploadComponents = baseURLComponents
            photoUploadComponents.path = uploadPhotoPath
            
            var request = MultipartRequest(url: photoUploadComponents.url!)
            request.addFormField(
                fieldName: "name",
                value: "page.name")
            request.addFile(
                fieldName: "photo",
                fileName: fileName,
                file: photo,
                fileType: fileType)
            request.addFormField(
                fieldName: "typeId",
                value: String("2"))
            
            request.sendRequest()
        }
}
