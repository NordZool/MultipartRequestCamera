//
//  Data+Extension.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import Foundation

extension Data {
    mutating func append(string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        
        self.append(data)
    }
}
