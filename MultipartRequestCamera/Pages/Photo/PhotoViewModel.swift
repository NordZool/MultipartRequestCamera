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
    
    //MARK: - Public properties
    var developerName: String
    var pageID: Int?
    //MARK: - Private properties
    private let networkService: PhotoNetworkService = .init()
    private var cancellable: Set<AnyCancellable> = .init()
    private let compressionQuality: CGFloat
    
    init(
        userName: String = "Фамилия Имя Отчество",
        pageID: Int? = nil,
        compressionQuality: CGFloat = 0.5) {
            self.developerName = userName
            self.pageID = pageID
            self.compressionQuality = compressionQuality
            subscribe(to: imageSubject)
        }
    
    func authorizedCameraAccess(complition: @escaping () -> ()) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { result in
                if result {
                   complition()
                }
            }
        case .authorized:
            complition()
        default:
            showAlertSubject.send(.cameraAccessError)
        }
    }
    
    private func subscribe(to imageSubject: CurrentValueSubject<UIImage?,Never>) {
        imageSubject
            .receive(on: DispatchQueue.global())
            .compactMap({$0})
            .sink { [weak self] image in
                if let compressionQuality = self?.compressionQuality,
                   let imageData = image?.jpegData(compressionQuality: compressionQuality),
                   let name = self?.developerName,
                   let typeId = self?.pageID {
                    
                    let fileName = "image\(UUID()).jpeg"
                    self?.networkService.uploadPhoto(
                        name: name,
                        typeId: typeId,
                        fileName: fileName,
                        photo: imageData,
                        complition: { result in
                            switch result {
                            case .success:
                                self?.showAlertSubject.send(.successPhotoUpload)
                            case .failure(let error):
                                print(error)
                                self?.showAlertSubject.send(.failedPhotoUpload)
                            }
                        })
                } else {
                    self?.showAlertSubject.send(.failedPhotoUpload)
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
