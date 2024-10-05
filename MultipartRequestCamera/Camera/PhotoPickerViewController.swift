//
//  PhotoPickerViewController.swift
//  MultipartRequestCamera
//
//  Created by nikita on 5.10.24.
//

import UIKit

class PhotoPickerViewController : UIImagePickerController {
    init() {
        super.init(nibName: nil, bundle: nil)
        let types = UIImagePickerController.availableMediaTypes(for: .camera) ?? []
        mediaTypes = types
        sourceType = .camera
        cameraFlashMode = .off
        cameraCaptureMode = .photo
        cameraDevice = .rear
        allowsEditing = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
