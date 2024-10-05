//
//  PhotoViewModel.swift
//  MultipartRequestCamera
//
//  Created by nikita on 5.10.24.
//

import Combine
import UIKit

final class PhotoViewModel {
    //MARK: - Subjects
    let imageSubject: CurrentValueSubject<UIImage?,Never> = .init(nil)
    let showAlertSubject: CurrentValueSubject<Bool,Never> = .init(false)
    
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
                                
                            }
                        })
                }
            }
            .store(in: &cancellable)
    }
}
