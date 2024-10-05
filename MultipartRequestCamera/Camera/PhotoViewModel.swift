//
//  PhotoViewModel.swift
//  MultipartRequestCamera
//
//  Created by nikita on 5.10.24.
//

import Combine
import UIKit
import AVFoundation

final class PhotoViewModel {
    //MARK: - Subjects
    let imageSubject: CurrentValueSubject<UIImage?,Never> = .init(nil)
    let showAlertSubject: CurrentValueSubject<AlertType?,Never> = .init(nil)
    
    //MARK: - Private properties
    private let networkService: PhotoNetworkService = .init()
    private var cancellable: Set<AnyCancellable> = .init()
    private let developerName: String
    private let pageID: Int
    
    init(
        userName: String = "Фамилия Имя Отчество",
        pageID: Int) {
            self.developerName = userName
            self.pageID = pageID
            subscribe(to: imageSubject)
        }
    
    func authorizeCameraAccess(complition: @escaping () -> ()) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { result in
                if result {
                    complition()
                }
            }
        } else {
            showAlertSubject.send(.cameraAccessError)
        }
        
    }
    
    private func subscribe(to imageSubject: CurrentValueSubject<UIImage?,Never>) {
        imageSubject
            .receive(on: DispatchQueue.global())
            .sink { [weak self] image in
                if let imageData = image?.jpegData(compressionQuality: 1),
                   let vm = self {
                    
                    let fileName = "image\(UUID()).jpeg"
                    vm.networkService.uploadPhoto(
                        name: vm.developerName,
                        typeId: vm.pageID,
                        fileName: fileName,
                        photo: imageData,
                        complition: { error in
                            if let error {
                                self?.showAlertSubject.send(.failedPhotoUpload)
                            } else {
                                self?.showAlertSubject.send(.successPhotoUpload)
                            }
                        })
                }
            }
            .store(in: &cancellable)
    }
}

enum AlertType {
    case successPhotoUpload
    case failedPhotoUpload
    case cameraAccessError
}
