//
//  PageType.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import Foundation

struct PageType : Codable {
    let page: Int
    let pageSize: Int
    let totalPages: Int
    let totalElements: Int
    let content: [PageContent]
}
