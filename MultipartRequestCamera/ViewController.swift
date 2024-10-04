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
        test.uploadPhoto(fileName: "image", photo: "data".data(using: .utf8)!)
        // Do any additional setup after loading the view.
    }


}

