//
//  URLRequest+Extension.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import Foundation

private struct MultipartRequest {
    ///Result url request
    private var request: URLRequest
    private let boundary: String
    
    init(url: URL, boundary: String = "\(UUID())") {
        request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue(
            "multipart/form-data; boundary=Boundary-\(boundary)",
            forHTTPHeaderField: "Content-Type")
        
        request.setValue(
            "*/*",
            forHTTPHeaderField: "accept")
        
        request.httpBody = Data()
        
        self.boundary = boundary
    }
    
    mutating func addFormField(
        fieldName: String,
        value: String) {
            var fieldString = "--Boundary-\(boundary)\r\n"
            fieldString += "Content-Disposition: form-data; name=\(fieldName)\r\n"
            fieldString += "\r\n"
            fieldString += "\(value)\r\n"
            
            request.httpBody!.append(string: fieldString)
        }
    
    
    mutating func addFile(
        fieldName: String,
        fileName: String,
        file: Data,
        fileType: FileType) {
            var data = Data()
            data.append(string: "--Boundary-\(boundary)\r\n")
            data.append(string: "Content-Disposition: form-data; name=\(fieldName); filename=\(fileName)\r\n")
            data.append(string:  "Content-Type: \(fileType.rawValue)\r\n")
            data.append(string: "\r\n")
            data.append(file)
            data.append(string: "\r\n")
            
            request.httpBody!.append(data)
        }
    
    mutating func sendRequest() {
        request.httpBody!.append(string: "--Boundary-\(boundary)--")
        
        let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200{
                print("Succes")
                print("\(String(data: data!, encoding: .utf8) ?? "error")")
            } else {
                print("Fail")
                print("response data: \(String(data: data!, encoding: .utf8) ?? "error")")
                print("sended header:\(self.request.allHTTPHeaderFields ?? ["":""])")
                print("sended data: \(String(data:self.request.httpBody!,encoding:.utf8) ?? "error")")
            }
        }
    }
}

//MARK: - FileType
extension MultipartRequest {
    enum FileType : String{
        case jpeg = "image/jpeg"
    }
}

