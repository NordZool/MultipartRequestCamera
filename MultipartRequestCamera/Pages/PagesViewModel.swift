//
//  PagesViewModel.swift
//  MultipartRequestCamera
//
//  Created by nikita on 4.10.24.
//

import Combine
import Foundation
import UIKit


class PagesViewModel {
    //MARK: - Public properties
    let pagesTypeSubject: CurrentValueSubject<[PageType],Never> = .init([])
    
    //MARK: - Private properties
    private let pagesNetworkService: PagesNetworkService = .init()
    private let backgroundQueue: DispatchQueue = .init(label: "backgroundPagesQueue", qos: .background)
    private let semaphore: DispatchSemaphore = .init(value: 1)
    private let cachedImages: NSCache<NSURL,UIImage> = .init()
    
    //MARK: - Public methods
    func uploadNewPage() {
        backgroundQueue.async {[weak self] in
            self?.semaphore.wait()
            
            let lastPageType = self?.pagesTypeSubject.value.last
            //-1 когда еще ни одной страницы нету в pagesTypeSubject
            let pageIndex = lastPageType?.page ?? -1
            let totalPages = lastPageType?.totalPages ?? -1
            
            if pageIndex != totalPages - 1 {
                
                self?.pagesNetworkService.getPageType(with: String(pageIndex + 1)) { result in
                    switch result {
                    case .success(let pageType):
                        self?.pagesTypeSubject.value.append(pageType)
                    case .failure(let failure):
                        print(failure)
                    }
                    self?.semaphore.signal()
                }
            } else {
                self?.semaphore.signal()
            }
        }
    }
    
    func loadImage(for pageContent: PageContent, complition: @escaping (UIImage?) -> ()) {
        
        guard let url = pageContent.imageURL else {
            complition(nil)
            return
        }
        let nsURL = NSURL(string: url)!
        
        if let cachedImage = cachedImages.object(forKey: nsURL) {
            complition(cachedImage)
        } else {
            //download image
            let task = URLSession.shared.dataTask(with: nsURL as URL) {[weak self] data, _, _ in
                guard let data = data else {
                    return
                }
                if let image = UIImage(data: data) {
                    self?.cachedImages.setObject(image, forKey: nsURL)
                    complition(image)
                } else {
                    complition(nil)
                }
            }
            task.resume()
        }
    }
}
