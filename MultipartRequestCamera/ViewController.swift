//
//  ViewController.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import UIKit

class ViewController: UIViewController {
    let test = PagesNetworkService()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        test.uploadPhoto(pageContent: .init(id: 10, name: "tester", image: nil), fileName: "image", photo: "data".data(using: .utf8)!)
        test.getPageType(with: "2") { result in
            
        }
        // Do any additional setup after loading the view.
    }
}

