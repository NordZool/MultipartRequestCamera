//
//  PageContent.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import Foundation
import UIKit

struct PageContent : Decodable {
    let id: Int
    let name: String
    let imageLink: String?
    
    let cachedImage: UIImage? = nil
}

//MARK: - CodingKeys
extension PageContent {
    enum CodingKeys: String, CodingKey {
        case id, name
        case imageLink = "image"
    }
}
