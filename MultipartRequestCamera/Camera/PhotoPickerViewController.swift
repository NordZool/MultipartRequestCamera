//
//  PhotoPickerViewController.swift
//  MultipartRequestCamera
//
//  Created by nikita on 5.10.24.
//

import UIKit

class PhotoPickerViewController : UIImagePickerController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let types = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
        mediaTypes = types
        sourceType = .camera
        cameraFlashMode = .off
        cameraCaptureMode = .photo
        cameraDevice = .rear
        allowsEditing = false
    }
}
