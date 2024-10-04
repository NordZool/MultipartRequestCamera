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
}
